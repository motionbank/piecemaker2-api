var config = require('./config.js');
var helper = require('./helper.js');
var models = require('./models.js');
var mysql = require('mysql');
var connect = require('connect');
var http = require('http');
var util = require('util');
var async = require('async');

var consoleEscapeCodes = {};
consoleEscapeCodes.red = '\u001b[31m';
consoleEscapeCodes.green = '\u001b[32m';
consoleEscapeCodes.yellow = '\u001b[33m';
consoleEscapeCodes.blue = '\u001b[34m';
consoleEscapeCodes.magenta = '\u001b[35m';
consoleEscapeCodes.cyan = '\u001b[36m';
consoleEscapeCodes.white = '\u001b[37m';
consoleEscapeCodes.bold = '\u001b[1m';
consoleEscapeCodes.reset = '\u001b[0m';

if (helper.isDevEnv()) config.mysql.debug = false;
var connection = mysql.createConnection(config.mysql);


var app = connect()

// establish mysql connection
.use(function(req, res, next) {
  if(!connection._connectCalled) {
    connection.connect(function(error) {
      if(error) {
        util.error(error);
        next(500, 'mysql unavailable');
      } else {
        next();
      }
    });
  } else {
    next();
  }
})

.use(connect.bodyParser())

// CORS middleware
// https://gist.github.com/3983284
.use( function(req, res, next) {
  var oneof = false;

  // @todo currently: "freifahrtschein" for all requests...
  // https://developer.mozilla.org/en-US/docs/HTTP/Access_control_CORS#Access-Control-Allow-Origin

  if(req.headers.origin) {
    res.setHeader('Access-Control-Allow-Origin', req.headers.origin);
    oneof = true;
  }
  if(req.headers['access-control-request-method']) {
    res.setHeader('Access-Control-Allow-Methods', req.headers['access-control-request-method']);
    oneof = true;
  }
  if(req.headers['access-control-request-headers']) {
    res.setHeader('Access-Control-Allow-Headers', req.headers['access-control-request-headers']);
    oneof = true;
  }
  if(oneof) {
    res.setHeader('Access-Control-Max-Age', 60 * 60 * 24 * 365);
  }

  // intercept OPTIONS method
  if (oneof && req.method == 'OPTIONS') {
    res.send(200);
  }
  else {
    next();
  }
})


// API ROUTER MIDDLEWARE
// =====================
.use(function(req, res, next) {

  // parse controller name from url
  // controller name must start with character followed by alphanumerics and/or underscores
  try {
    var controllerName = req.url.match(/^\/([a-z][a-z0-9_]*)/)[1];
  } catch (e) {
    return next(404, 'invalid controller name');
  }

  util.log(consoleEscapeCodes.cyan + consoleEscapeCodes.bold + '[api] request ' + req.method + ' ' + req.url + ' ('+ JSON.stringify(req.body) +')' + consoleEscapeCodes.reset); // do some logging

  // @todo send hello if empty url

  // load controller and the routes
  // controllerName should be safe here, only contains a-z and _
  try {
    // load controller in pluralized form
    var router = require('./controllers/' + controllerName + '.js');
  } catch (e) {
    try {
      // load controller if in singularized form
      var router = require('./controllers/' + controllerName + 's.js');
    } catch (e) {
      // if no controller was found ...
      return next(404, 'controller not found');
    }
  }

  // route request ...
  if (Object.keys(router).length == 0) return next(404, 'route not found');

  // parse request elements
  // @todo make sure that req.url starts with /
  var requestElements = helper.rtrim(req.url, '/').split('/').slice(1);
  var requestElementsLength = requestElements.length;

  // loop over all found routes from controller
  var match = false;
  var routerKeys = Object.keys(router);
  var routerKeysLength = routerKeys.length;
  for (var j = 0; j < routerKeysLength; j++) {
    var route = routerKeys[j];
    if (helper.isDevEnv()) util.debug('checking route: ' + route);

    // @todo make sure that route starts with /

    // parse elements for this route
    var routeElements = helper.rtrim(route, '/').split('/');
    var requestParams = []; // holds :params from request

    // verify http method
    var routeMethod = routeElements.shift().trim();
    if (~config.allowHttpMethods.indexOf(routeMethod) && routeMethod == req.method.toUpperCase()) {
      // verify elements length from route and request
      if (routeElements.length == requestElementsLength) {
        // see if elements from route and request match
        match = true;
        for (var i = 0; i < requestElementsLength; i++) {
          if (routeElements[i] == requestElements[i]) {
            // elements match perfectly
          } else if (routeElements[i] == ':int' && !isNaN(requestElements[i] - 0)) {
            // found an integer
            requestParams.push(requestElements[i]);
          } else if (routeElements[i] == ':string' && isNaN(requestElements[i] - 0)) {
            // found a string which is not an integer
            requestParams.push(requestElements[i]);
          } else {
            // no match, stop loop
            match = false;
            break;
          }
        }

        // did we find a route match?
        if (match) {
          if (helper.isDevEnv()) util.debug('using route ' + route + ' with params [' + requestParams + ']');


          var errorCallback = function(http, message) { 
            return next(http, message);
          };


          var renderCallback = function(content) {
            // parse content to JSON
            try {
              content = JSON.stringify(content);
            } catch (e) {
              return next(500, 'could not parse content to JSON');
            }

            // send content back to client
            res.setHeader('Content-Type', 'application/json');
            res.end(content);

            // close connection
            //connection.end(function(error) {
            //  if(error) util.error(error);
            // });

            if (helper.isDevEnv()) util.debug(consoleEscapeCodes.cyan + 'return ' + content + consoleEscapeCodes.reset);  
          }

          // pass some vars to the function
          var api = { error: errorCallback, 
                      render: renderCallback,
                      db: connection, 
                      params: req.body,
                      req: req, 
                      res: res, 
                      h: helper, 
                      m: models,
                      async: async,
                      config: config};

          requestParams.unshift(api);

          // finally ... execute method from controller
          router[route].apply(null, requestParams);

          // since we found a route, do not check further routes
          break;
        }
      }
    }
  }

  // there was no match!
  if(!match) return next(404, 'route not found');

})

// @todo auto jsonp return!? middleware

// ERROR HANDLER MIDDLEWARE
// ========================
.use(function(err, req, res, next) {

  if(!err.status) err.status = 500;

  // send error to client
  res.statusCode = err.status < 400 ? 500 : err.status;
  res.writeHead(res.statusCode, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify( {http: res.statusCode, error: err.message} ));

  if(config.env == 'development') {
    util.error(consoleEscapeCodes.red + '[api] ' + res.statusCode + ' ' + err.message + consoleEscapeCodes.reset);
    util.error(consoleEscapeCodes.white + '[api] ' + err.stack + consoleEscapeCodes.reset);
  } else {
    // util.error('[api] ' + res.statusCode + ' ' + err.stack); // log to file
  }


  // // copy & paste with some modifications from http://www.senchalabs.org/connect/errorHandler.html
  // if (err.status) res.statusCode = err.status;
  // if (res.statusCode < 400) res.statusCode = 500;
  // var accept = req.headers.accept || '';
// 
  // // handle json
  // if (~accept.indexOf('json')) {
  //   var error = {message: err.message, statusCode: res.statusCode};
  //   if (config.env == 'development') error.stack = err.stack;
  //   for (var prop in err) error[prop] = err[prop];
  //   var json = JSON.stringify({ error: error });
  //   res.setHeader('Content-Type', 'application/json');
  //   res.end(json);
  // // plain text
  // } else {
  //   res.writeHead(res.statusCode, { 'Content-Type': 'text/plain' });
  //   res.end('(HTTP ' + res.statusCode + ') ' + (config.env == 'development' ? err.stack : err.message));
  // }
});


// start server and listen ...
http.createServer(app).listen(config.port, function() {
  util.log('[api] listening at port ' + config.port);
});




