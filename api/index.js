var mysql      = require('mysql');
var express = require('express');
var app = express();


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


app.listen(8081);
console.log('Listening on port 8081');