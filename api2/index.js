var API = require('../../node-rest-api/lib/api.js');
var util = require('util');

var config = require('./config.js');
var mysql = require('mysql');


var api = new API({
  port: 8081,
  env: 'development',
  accessLog: './logs/access_log',
  errorLog: './logs/error_log',
  controllers: './controllers',
  cors: true,
  jsonp: false
});

// mysql config
var pool = mysql.createPool(config.mysql);

// get mysql connection from pool before function is actually called
api.beforeFunctionCall(function(api, req, res, next){
  pool.getConnection(function(err, db){
    if(err) throw new Error('no database connection');
    api.setHandle('db', db);
    next();
  });
});

// release mysql connection
api.beforeResponse(function(api, req, res, next){
  api.handles.db.end();
  next();
});


// auth hook
// if AUTH flag is set, validate user and quit if validation fails
api.beforeFunctionCall('AUTH', function(api, req, res, next){
  console.log('AUTH1');
  try {
    if(req.api.params.token == '123') {
      // get user from db with token
      req.api.user = {id: 2, name: 'harald'};
      next();
    } else {
      throw new ClientError({status: 403, message: 'invalid login'});
    }
  } catch(e) {
    throw new ClientError({status: 401, message: 'login invalid'});
  }
});

// prepare auth hook
// use $.req.user for further validations
api.beforeFunctionCall('PREPARE_AUTH', function(api, req, res, next){
  console.log('PREPARE_AUTH');
  try {
    if(req.api.params.token == '123') {
      // get user from db with token
      req.api.user = {id: 2, name: 'harald'};
    }
  } catch(e) {
    req.api.user = false;
  }
  next();
});



// show me what you got
// console.log("List of all routes:\n", util.inspect(api.listRoutes(), false, 5, true));



api.start(function() {
  // api is ready

});

// api.reload();
// api.stop();

// console.log(api.controllers);