var express = require('express');
var orm = require('orm');
var app = express();
var config = require('./config/' + app.get('env') + '.js')(app);

app.use(orm.express(config.db, {
    define: function (db, models) {
        // models.person = db.define("person", { ... });
    }
}));