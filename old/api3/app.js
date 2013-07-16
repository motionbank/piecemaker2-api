var express = require('express');
var orm = require('orm');
var app = express();

// load config
var config = require('./config/' + app.get('env') + '.js')(app, express, orm);

// load models
app.use(orm.express(config.db, {
  define: function (db, models) {

    db.load("./models/user.js", function(err) {
      if(err) throw err;
      User = db.models.users
    });

  }
}));


app.get("/users", function (req, res) { 
  User.find({}, function(err, users) {
    res.json(users);
  });
});

