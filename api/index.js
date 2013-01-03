var mysql = require('mysql');
var restify = require('restify');

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


var server = restify.createServer({
  name: 'piecemaker'
});
server.use(restify.acceptParser(['application/json']));
server.use(restify.authorizationParser());


server.get('/hello/:name', function(req, res, next){
  res.send({ola: 'hello ' + req.params.name});
});



server.listen(8080, function() {
  console.log('%s listening at %s', server.name, server.url);
});





var connection = mysql.createConnection({
  host     : 'kb-server.de',
  user     : 'd015dedf',
  password : 'QUtNzpy3QF25gv3E',
});

connection.connect();

connection.query('SELECT 1 + 1 AS solution', function(err, rows, fields) {
  if (err) throw err;

  console.log('The solution is: ', rows[0].solution);
});

connection.end();


