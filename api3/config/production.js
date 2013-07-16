module.exports = function(app, express, orm) {

  // https://github.com/dresende/node-orm2#options
  // var db = {
    // database : "piecemaker2",
    // protocol : "mysql",
    // host     : "127.0.0.1",
    // port     : 3306,         // optional, defaults to database default
    // user     : "root",
    // password : "",
    // query    : {
      // pool     : true,   // optional, false by default
      // debug    : false   // optional, false by default
    // }
  // };

  var db = {
    database : "piecemaker2",
    protocol : "postgres",
    host     : "127.0.0.1",
    // port     : 3306,         // optional, defaults to database default
    user     : "mattes",
    password : "",
    query    : {
      pool     : true,   // optional, false by default
      debug    : false   // optional, false by default
    }
  };

  app.listen(9050);
  // app.use(express.logger());

  return {db: db}

};