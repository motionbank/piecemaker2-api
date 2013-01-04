/*
 * Model Definitions
 * see http://www.sequelizejs.com/#models-definition
 */

// sequelize instance, Sequelize class
module.exports = function(sequelize, Sequelize) {
  var Model = {

    User: sequelize.define('user', {
      id: {type: Sequelize.INTEGER, primaryKey: true, autoIncrement: true},
      name: {type: Sequelize.STRING},
      email: {type: Sequelize.STRING},
      password: {type: Sequelize.STRING},
      api_access_key: {type: Sequelize.STRING},
      is_admin: {type: Sequelize.BOOLEAN},
      is_disabled: {type: Sequelize.BOOLEAN}
    }),

    Event: sequelize.define('event', {
      id: {type: Sequelize.INTEGER, primaryKey: true, autoIncrement: true},
      utc_timestamp: {type: Sequelize.STRING},
      duraction: {type: Sequelize.STRING}
    })

  };

  // define associations
  // see http://www.sequelizejs.com/#associations
  Model.User.hasMany(Model.Event, {foreignKey: 'created_by_user_id'});


  return Model;
}