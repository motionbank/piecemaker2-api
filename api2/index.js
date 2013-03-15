var API = require('../../node-rest-api/lib/api.js');
// var API = require('rest-api');

var util = require('util');


var config = require('./config/test.js');
var mysql = require('mysql');


var api = new API({
  port: 8081,
  accessLog: './logs/access_log',
  errorLog: './logs/error_log',
  controllers: './controllers',
  cors: true,
  jsonp: false
});

// mysql config
var pool = mysql.createPool(config.mysql);

// get mysql connection from pool before function is actually called
// api.beforeFunctionCall(function(api, req, res, next){
//   pool.getConnection(function(err, db){
//     if(err) throw new Error('no database connection');
// 
//     db.on('error', function(err) {
//       if (!err.fatal) return;
//       // we can ignore this error, because of pooling
//       if (err.code !== 'PROTOCOL_CONNECTION_LOST') throw err;
//     });
// 
//     api.setHandle('db', db);
//     next();
//   });
// });


api.hook('beforeFunctionCall', function(_api, req, res, next){
  pool.getConnection(function(err, db){
    if(err) throw new Error('no database connection');

    db.on('error', function(err) {
      if (!err.fatal) return;
      // we can ignore this error, because of pooling
      // @TODO this is wrong!!! we need to care!
      if (err.code !== 'PROTOCOL_CONNECTION_LOST') throw err;
    });

    // api.setHandle('db', db);
    api.handles['db'] = db;
    // next();
  });
});




// release mysql connection
api.hook('cleanup', function(_api, req, res, next) {
  console.log('cleanupFunc called!!!');
  try {
    // api.handles.db.end();  
  } catch(e) {console.log('cleanupFunc issues');}

  // next();
});



// auth hook
// if AUTH flag is set, validate user and quit if validation fails
api.hook('beforeFunctionCall', 'AUTH', function(api2, req, res, next){
  // try {
    
    api2.handles.db.query('SELECT * FROM users WHERE api_access_key=? LIMIT 1',
      [req.api.params.token],
      function(err, result){
        console.log("err", err);
        console.log("result", result);
        if(err || result.length !== 1) throw new ClientError({status: 403, message: 'invalid login'});
        api.user = result[0];
        // next();
      }
    );
  //} catch(e) {
    // throw new ClientError({status: 401, message: 'login invalid'});
  //  throw e;
  // }
});

// prepare auth hook
// use $.req.user for further validations
// api.beforeFunctionCall('PREPARE_AUTH', function(api, req, res, next){
//   try {
//     if(req.api.params.token == '123') {
//       // get user from db with token
//       req.api.user = {id: 2, name: 'harald'};
//     }
//   } catch(e) {
//     req.api.user = false;
//   }
//   next();
// });



// show me what you got
// console.log("List of all routes:\n", util.inspect(api.listRoutes(), false, 5, true));



api.start(function() {
  // api is ready
  
});

// api.reload();
// api.stop();

// console.log(api.controllers);