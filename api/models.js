/*
 * Model Definitions
 * see http://www.sequelizejs.com/#models-definition
 */

// _s_equelize = instance, _S_equelize = class
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
      event_group_id: {type: Sequelize.INTEGER}, // @todo required?
      created_by_user_id: {type: Sequelize.INTEGER}, // @todo required?
      utc_timestamp: {type: Sequelize.STRING},
      duration: {type: Sequelize.STRING}
    }),

    EventField: sequelize.define('event_field', {
      event_id: {type: Sequelize.INTEGER}, // @todo required?
      id: {type: Sequelize.STRING, primaryKey: true},
      value: {type: Sequelize.TEXT}
    }),

    EventGroup: sequelize.define('event_group', {
      id: {type: Sequelize.STRING, primaryKey: true, autoIncrement: true},
      title: {type: Sequelize.STRING},
      text: {type: Sequelize.TEXT}
    }),

    // @todo is this definition required?
    UserEventGroup: sequelize.define('user_has_event_group', {
      user_id: {type: Sequelize.INTEGER},
      event_group_id: {type: Sequelize.INTEGER},
      allow_create: {type: Sequelize.BOOLEAN},
      allow_read: {type: Sequelize.BOOLEAN},
      allow_update: {type: Sequelize.BOOLEAN},
      allow_delete: {type: Sequelize.BOOLEAN}
    })

  };

  // define associations
  // see http://www.sequelizejs.com/#associations
  Model.User.hasMany(Model.Event, {foreignKey: 'created_by_user_id'});
  Model.User.hasMany(Model.EventGroup, {joinTableName: 'user_has_event_groups'});
  Model.EventGroup.hasMany(Model.User, {joinTableName: 'user_has_event_groups'});
  Model.EventGroup.hasMany(Model.Event);
  Model.Event.belongsTo(Model.EventGroup);
  Model.Event.belongsTo(Model.User);
  Model.Event.hasMany(Model.EventField);
  Model.EventField.belongsTo(Model.Event);

  return Model;
}