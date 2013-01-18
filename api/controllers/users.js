module.exports = {

  'GET /users':
  function() {
    return 'get all users';
  },

  'GET /user/:int':
  function(user_id) {
    return 'get user with id ' + user_id;
  },

  'GET /user/peter':
  function() {
    return 'get user with name peter';
  },

  'GET /users/:string':
  function(name) {
    return 'get all users with name ' + name;
  },

  'GET /user/:int/events/:int':
  function(user_id, event_id) {

    // console.log(this.db);

    return {foobar: 'get all events with id ' + event_id + ' for user with id ' + user_id};
  },

  'DEL /user/:int/event_groups':
  function(user_id) {
    return 'delete all event groups for user with id ' + user_id;
  }

};
