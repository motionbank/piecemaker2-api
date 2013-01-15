var config = require('./config.js');
var mysql = require('mysql');
var connection = mysql.createConnection(config.mysql);

var express = require('express');
var app = express();


app.get('/', function(req, res){
  res.send('Hello World');
});

app.listen(3000);

connection.destroy();

// var connect = require('connect');
// var http = require('http');
// var Sequelize = require("sequelize");
// var sequelize = new Sequelize(config.sequelize.database, config.sequelize.username, config.sequelize.password, config.sequelize.options);
// var Model = require('./models.js')(sequelize, Sequelize); // model definitions
// 
// 
// 
// Model.User.findAll().success(function(users) {
//   console.log(users);
//   console.log(users[0].getEvents());
// });
// 
// 
// 
// var app = connect()
//   // .use(connect.cookieParser())
//   // .use(connect.session({ secret: 'my secret here' }))
//   .use(function(req, res){
//     res.end('Hello from Connect!\n');
//   });
// 
// http.createServer(app).listen(8080, function() {
//   console.log('api listening at port 8080');
// });






/*
  users
  events
  event_fields
  event_groups

  GET  /users
  POST /user
  GET  /user/:id
  PUT  /user/:id
  DEL  /user/:id

  GET  /user/:id/events
  GET  /user/:id/event_groups

  GET  /events
  POST /event
  GET  /event/:id (with event_group and created_by_user and fields)
  PUT  /event/:id
  DEL  /event/:id

  (GET  /event/:id/fields)
  GET  /event/:id/field/:key
  POST /event/:id/field
  PUT  /event/:id/field/:key
  DEL  /event/:id/field/:key

  GET  /event_groups
  GET  /event_group/:id
  POST /event_group
  PUT  /event_group/:id
  DEL  /event_group/:id

  
*/