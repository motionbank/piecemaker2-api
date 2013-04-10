// empty all tables and insert dummy data

var config = require('../config.js');
var connect = require('connect');
var http = require('http');
var Sequelize = require("sequelize");
var sequelize = new Sequelize(config.sequelize.database, config.sequelize.username, config.sequelize.password, config.sequelize.options);
var Model = require('../models.js')(sequelize, Sequelize); // model definitions
var chainer = new Sequelize.Utils.QueryChainer


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

      chainer
        .add( Model.User.create({id: 1, name: 'Martin', email: 'martin@h-da.de', password: 'martin', api_access_key: 'martin', is_admin: true}) )
        .add( Model.EventGroup.create({id: 1, title: 'Eins'}) )
        .add( Model.UserEventGroup.create({user_id: 1, event_group_id: 1, allow_create: true}) )
        .add( Model.Event.create({id: 1, event_group_id: 1, created_by_user_id: 1, utc_timestamp: 1, duration: 1}) )
        .add( Model.EventField.create({event_id: 1, id: 'type', value: 'marker'}) )
      chainer.run().error(function(err){}).success(function(result){});
        


      Model.User.create({name: 'Matthias', email: 'matthias@h-da.de', password: 'matthias', api_access_key: 'matthias', is_admin: true});
      Model.User.create({name: 'Peter', email: 'peter@h-da.de', password: 'peter', api_access_key: 'peter', is_admin: true});

        
        /*
        Model.EventGroup.create({title: 'Eins'}).success(function(eventGroup){
          user.addEventGroup(eventGroup).success(function(foo){
            user.getEventGroups().success(function(foo){
              console.log(foo);
            })
          });
        });
        */

        

        
        // console.log(user.getEventGroups());
      // });
  
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