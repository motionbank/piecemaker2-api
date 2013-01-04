// empty all tables and insert dummy data

var config = require('../config.js');
var connect = require('connect');
var http = require('http');
var Sequelize = require("sequelize");
var sequelize = new Sequelize(config.sequelize.database, config.sequelize.username, config.sequelize.password, config.sequelize.options);
var Model = require('../models.js')(sequelize, Sequelize); // model definitions

var readline = require('readline');
var rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});


rl.question("Delete ALL records in ALL tables and create NEW records? [yes|no] ", function(answer) {
  if(answer == 'yes') {
    console.log('Alright, deleting ...');


    // -------------------------------------------




    truncate(['user_has_event_groups', 'event_groups', 'event_fields', 'events', 'users'], create);

    // create records
    function create() {

      Model.User.create({name: 'Martin', email: 'martin@h-da.de', password: 'martin', api_access_key: 'martin', is_admin: true});


    }






    // -------------------------------------------

  } else {
    console.log('Nothing was changed.');
  }
  rl.close();
});

// truncate tables asynchronously
function truncate(tables, callback) {
  if(tables.length > 0) {
    var table = tables.shift();
    sequelize.query('TRUNCATE TABLE ' + table, null, {raw: true}).success(function(data){
      if(tables.length > 0) {
        truncate(tables, callback);
      } else {
        callback.call(null);
      }
    });
  } 
}