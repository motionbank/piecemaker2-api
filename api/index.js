var config = require('./config.js');
var mysql = require('mysql');
var connection = mysql.createConnection(config.mysql);

var connect = require('connect')
var http = require('http');




connection.destroy();



var app = connect()
  // .use(connect.cookieParser())
  // .use(connect.session({ secret: 'my secret here' }))


  // API ROUTER MIDDLEWARE
  // =====================
  .use(function(req, res, next){
    

    // find first a-z and _ in url.
    // example /controller/:id = controller
    try {
      var controllerName = req.url.match(/^\/([a-z_]+)/)[1];
    } catch(e) {
      console.log(e);
    }
    
    // load controller and delegate execution
    // controllerName should be safe here, only contains a-z and _
    try {
      require('./controllers/' + controllerName + '.js').call(null, req, res, next);
    } catch(e) {
      console.log(e);
    }

    // res.end('Hello from Connect!\n');
  });



http.createServer(app).listen(8080, function() {
  console.log('api listening at port 8080');
});







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