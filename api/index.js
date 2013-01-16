var config = require('./config.js');
var helper = require('./helper.js');
var mysql = require('mysql');
var connect = require('connect')
var http = require('http');


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

  // connect to database
  try {
    if(config.env == 'development' && config.mysql.debug) config.mysql.debug = false;
    var connection = mysql.createConnection(config.mysql);
  } catch(e) {
    helper.throwNewEnvError(e);
  }
  
  // build params for controller 
  

  // load controller and delegate execution
  // controllerName should be safe here, only contains a-z and _
  try {
    var content = require('./controllers/' + controllerName + '.js').call(null, req, res, connection); // @todo params ...
  } catch(e) { 
    helper.throwNewEnvError(e, 'controller not found');
  }

  // verify if controller has return statement
  if(typeof content == 'undefined') helper.throwNewEnvError('missing return statement in controller ' + controllerName);

  // return content
  res.end(content); 

  // @todo auto jsonp return!?

  // close connection
  connection.destroy();
  
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
http.createServer(app).listen(8080, function() {
  console.log('api listening at port 8080');
});




