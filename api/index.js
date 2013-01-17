var config = require('./config.js');
var helper = require('./helper.js');
var mysql = require('mysql');
var connect = require('connect')
var http = require('http');
var util = require('util');


var app = connect()
// .use(connect.cookieParser())
// .use(connect.session({ secret: 'my secret here' }))

// @todo cors middleware

// API ROUTER MIDDLEWARE
// =====================
.use(function(req, res, next){
  
  // parse controller name from url
  // controller name must start with character followed by alphanumerics and/or underscores
  try {
    var controllerName = req.url.match(/^\/([a-z][a-z0-9_]*)/)[1];
  } catch(e) {
    helper.throwNewEnvError('invalid controller name. controller name must start with character followed by alphanumerics and/or underscores. ', 'invalid controller name');
  }

  util.log('[api] request ' + req.url); // do some logging
  
  // load controller and the routes
  // controllerName should be safe here, only contains a-z and _
  try {
    var router = require('./controllers/' + controllerName + '.js');
  } catch(e) { 
    helper.throwNewEnvError(e, 'controller not found');
  }

  // route request ...
  if(Object.keys(router).length == 0) helper.throwNewEnvError('no routes defined in controllers/' + controllerName + '.js', 'route not found');

  // parse request elements
  var requestElements = helper.rtrim(req.url, '/').split('/').slice(1);
  var requestElementsLength = requestElements.length;

  // loop over all found routes from controller
  var routerKeys = Object.keys(router);
  var routerKeysLength = routerKeys.length;
  for(var j=0; j < routerKeysLength; j++) {
    var route = routerKeys[j];
    if(helper.isDevEnv()) util.debug('checking route: ' + route);
    
    // parse  elements for this route
    var routeElements = helper.rtrim(route, '/').split('/');
    var requestParams = []; // holds :params from request

    // verify http method
    var routeMethod = routeElements.shift().trim();
    if(~config.allowHttpMethods.indexOf(routeMethod) && routeMethod == req.method.toUpperCase()) {
      // verify elements length from route and request
      if(routeElements.length == requestElementsLength) {
        // see if elements from route and request match
        var match = true;
        for(var i=0; i < requestElementsLength; i++) {
          if(routeElements[i] == requestElements[i]) {
            // elements match perfectly
          } else if(routeElements[i] == ':int' && !isNaN(requestElements[i]-0)) {
            // found an integer
            requestParams.push(requestElements[i]);
          } else if(routeElements[i] == ':string') {
            // well, taking this as string
            requestParams.push(requestElements[i]);
          } else {
            // no match, stop loop
            match = false;
            break;
          }
        }

        // did we find a route match?
        if(match) {
          if(helper.isDevEnv()) util.debug('using route ' + route + ' with params [' + requestParams + ']');

          // connect to database
          try {
            if(helper.isDevEnv() && config.mysql.debug) config.mysql.debug = false;
            var connection = mysql.createConnection(config.mysql);
          } catch(e) {
            helper.throwNewEnvError(e);
          }

          // pass some instances to the function
          var that = {db: connection, req: req, res: res, h: helper, config: config};

          // finally ... execute method from controller and fetch returned content
          var content = router[route].apply(that, requestParams);

          // close connection
          connection.destroy();          

          // verify if controller has return statement
          if(typeof content == 'undefined') helper.throwNewEnvError('missing return statement in controller ' + controllerName);

          // since we found a route, do not check further routes
          break; 
        }
      }
    }
  }

  // was there a match?!
  if(!match) helper.throwNewEnvError('unable to find matching route in controllers/' + controllerName + '.js', 'route not found');

  // parse content to JSON
  try {
    content = JSON.stringify(content);
  } catch(e) {
    helper.throwNewEnvError('could parse content to JSON: ' + e);
  }

  // return content to client
  res.end(content); 

  if(helper.isDevEnv()) util.debug('return ' + content);

  // @todo auto jsonp return!?
  
})

// ERROR HANDLER MIDDLEWARE
// ========================
.use(function(err, req, res, next){
  // copy & paste with some modifications from http://www.senchalabs.org/connect/errorHandler.html
  if(err.status) res.statusCode = err.status;
  if(res.statusCode < 400) res.statusCode = 500;
  var accept = req.headers.accept || '';

  // handle json
  if(~accept.indexOf('json')) {
    var error = {message: err.message, statusCode: res.statusCode};
    if(config.env == 'development') error.stack = err.stack;
    for (var prop in err) error[prop] = err[prop];
    var json = JSON.stringify({ error: error });
    res.setHeader('Content-Type', 'application/json');
    res.end(json);
  // plain text
  } else {
    res.writeHead(res.statusCode, { 'Content-Type': 'text/plain' });
    res.end('(HTTP ' + res.statusCode + ') ' + (config.env == 'development' ? err.stack : err.message));
  }
});

// start server and listen ...
http.createServer(app).listen(config.port, function() {
  util.log('[api] listening at port ' + config.port);
});




