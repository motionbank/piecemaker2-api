module.exports = function(app) {

  // https://github.com/dresende/node-orm2#options
  var db = {
    database : "piecemaker2",
    protocol : "mysql",
    host     : "127.0.0.1",
    port     : 3306,         // optional, defaults to database default
    user     : "root",
    password : "",
    query    : {
      pool     : true,   // optional, false by default
      debug    : true   // optional, false by default
    }
  };

  return {db: db}

};