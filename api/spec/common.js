var mysql = require('mysql');
var fs = require('fs');
var spawn = require('child_process').spawn;
var config = require('../config/test.js');
var api;
connection = null; // global!

var createDb = function(done) {
  var mysqlDump = fs.readFileSync('./spec/db/create-db.sql', 'utf8');
  if(!mysqlDump) return done(new Error('empty create-db.sql'));
  connection.query(mysqlDump, function(err, result){
    if(err) return done(err);
    done();
  });  
}

var deleteDb = function(done) {
  var mysqlDump = fs.readFileSync('./spec/db/delete-db.sql', 'utf8');
  if(!mysqlDump) return done(new Error('empty delete-db.sql'));
  connection.query(mysqlDump, function(err, result){
    if(err) return done(err);
    done();
  });  
}

var insertTestData = function(done) {
  var mysqlDump = fs.readFileSync('./spec/db/insert-test-data.sql', 'utf8');
  if(!mysqlDump) return done(new Error('empty insert-test-data.sql'));
  connection.query(mysqlDump, function(err, result){
    if(err) return done(err);
    done();
  }); 
}


before(function(done){
  // set up db
  config.mysql['multipleStatements'] = true;
  connection = mysql.createConnection(config.mysql);
  connection.connect(function(err){
    if(err) return done(err);

    // to be safe delete first
    deleteDb(function(err){
      if(err) return done(err);

      // add new tables
      createDb(function(err){
        if(err) return done(err);

        insertTestData(function(err){
          if(err) return done(err);

          // start api
          api = spawn('node', ['api.js', '--env', 'test']);

          api.stdout.on('data', function (data) {
            // console.log('stdout: ' + data);
            done();
          });

          api.stderr.on('data', function (data) {
            console.log('stderr: ' + data);
          });

          // api.on('close', function (code) {
          //   console.log('child process exited with code ' + code);
          // });

          
        });
      });
    });
  });
});


after(function(done){
  // stop api
  api.kill();

  deleteDb(function(err){
    if(err) return done(err);
    connection.end(function(err){
      if(err) return done(err);

      done();
    })
  });
});


// delay every spec test 
beforeEach(function(done) {
  setTimeout(function(){done()}, 500);
});