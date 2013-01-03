var mysql = require('mysql');
var restify = require('restify');

/*
  users

  events

  event_fields

  event_groups



*/



function respond(req, res, next) {
  res.send('hello ' + req.params.name);
}

var server = restify.createServer();
server.get('/hello/:name', respond);
server.head('/hello/:name', respond);

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


