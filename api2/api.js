#!/usr/bin/env node

var API = require('../../node-rest-api/lib/api.js');
// var API = require('rest-api');


// command line option parser ...
var program = require('commander');
program
  .version('0.0.2')
  .option('-e, --env [env]', 'Specify environment (production|development|test)')
  .parse(process.argv);

var ENV = program.env || 'production';
if(!~['production', 'development', 'test'].indexOf(ENV)) throw new Error('invalid ENV');

var util = require('util');
var config = require('./config/' + ENV + '.js');
var mysql = require('mysql');

var api = new API(config.api);
var pool = mysql.createPool(config.mysql);

// ---- add hooks
api.beforeFunctionCall(function(req, res, next){
  pool.getConnection(function(err, db){
    if(err) throw new ClientError({status: 503, message: 'database timeout'});
    api.setHandle('db', db);
    next();
  });
});

api.beforeResponse(function(req, res, next) {
  try {
    // release mysql connection
    api.handles.db.end();  
  } catch(e) {
    throw new Error('unable to release connection from pool');
    // continue though ... see what happens
  }
  next();
});

// auth hook
// if AUTH flag is set, validate user and quit if validation fails
api.beforeFunctionCall('AUTH', function(req, res, next){
  try {
    api.handles.db.query('SELECT * FROM users WHERE api_access_key=? LIMIT 1',
      [req.api.params.token],
      function(err, result){
        if(err || result.length !== 1) throw new ClientError({status: 403, message: 'invalid login'});
        api.user = result[0];
        next();
      }
    );
  } catch(e) {
    throw new ClientError({status: 401, message: 'login invalid'});
  }
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


// ---- start the API ...
api.start(function() {
  // api is ready
  util.log('[api] listening at port ' + api.options.port + ' in ' + ENV + ' environment');
});