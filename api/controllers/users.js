module.exports = {

  /* Put all your controller routes and functions in this file.
   * Example:
   *  'GET /users/:int':
   *  function(user_id) {
   *    // access mysql db with this.db
   *    return 'get user with id ' + user_id;
   *  }
   */
  

  'GET /users': 
  function() {
    return 'get all users';
  },

  'GET /users/:int': 
  function(user_id) {
    return 'get user with id ' + user_id;
  },

  'GET /users/peter': 
  function() {
    return 'get all users with name peter';
  },    

  'GET /users/:string': 
  function(name) {
    return 'get all users with name ' + name;
  },       

  'GET /users/:int/events/:int': 
  function(user_id, event_id) {

    // console.log(this.db);

    return 'get all events with id ' + event_id + ' for user with id ' + user_id;
  },

  'DEL /users/:int/event_groups': 
  function(user_id) {
    return 'delete all event groups for user with id ' + user_id;
  }

};
