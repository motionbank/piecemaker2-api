var API = require('../../node-rest-api/lib/api.js');
var util = require('util');

// mysql config
connection = 1;




// auth handler
var auth = function(request) {
  try {
    if(request.params.query.token == '123') {
      // get user from db with token

      return {id: 2, name: 'harald'};
    }
  } catch(e) {
    return false;
  }
}



var api = new API({
  port: 8081,
  env: 'development',
  accessLog: './logs/access_log',
  errorLog: './logs/error_log',
  controllers: './controllers',
  dbHandle: connection,
  authHandle: auth,
  cors: true,
  jsonp: true
});


api.beforeFunctionCall('AUTH', function(req, res, next) {
  console.log(':: beforeFunctionCall :: auth');
  next();
});


api.beforeRender('PENG', function(req, res, next) {
  console.log(':: beforeRender :: peng2');
  
  next();
});

api.beforeRender('PENG', function(req, res, next) {
  console.log(':: beforeRender :: peng1');
  next();
});

api.beforeRender(function(req, res, next) {
  console.log(':: beforeRender :: i am always called at first (*)');
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