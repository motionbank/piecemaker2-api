var config = require('./config.js');
var mysql = require('mysql');
var connect = require('connect')
var http = require('http');


if(config.env == 'development' && config.mysql.debug) config.mysql.debug = false;
var connection = mysql.createConnection(config.mysql);


connection.destroy();



var app = connect()
// .use(connect.cookieParser())
// .use(connect.session({ secret: 'my secret here' }))


// API ROUTER MIDDLEWARE
// =====================
.use(function(req, res, next){
  
  // parse controller name from url
  // controller name must start with character followed by alphanumerics and/or underscores
  try {
    var controllerName = req.url.match(/^\/([a-z][a-z0-9_]*)/)[1];
  } catch(e) {
    throw new Error('invalid controller name');
  }
  
  // load controller and delegate execution
  // controllerName should be safe here, only contains a-z and _
  try {
    require('./controllers/' + controllerName + '.js').call(null, req, res, next);
  } catch(e) {
    throw new Error('controller not found');
  }
  
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



