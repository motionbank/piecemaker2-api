piecemaker API
==============

Usage
-----
 * Get latest version from github
 * node index.js or nodemon index.js (see [nodemon](https://github.com/remy/nodemon))


Directory Structure
-------------------
```
/index.js     execute this file, it sets up the "framework" and dispatches all api requests
/config.js    configuration is done here
/helper.js    has some nifty helper methods
/package.json npm information about this package
/controllers  put all your controllers and routes in this directory
/node_modules external node libs (you probably don't want to change anything here)
/tests        unit tests for api (@todo)
```

Controllers
-----------
A short tutorial on how to create a controller file, i.e. for users.

 * Create file __users__.js in /controllers (the filename equals the first part of the REST-URL, i.e. GET <notextile>/</notextile>__users__/1)
 * Controller names must start with a character followed by alphanumerics and/or underscores
 * Put your routes and according functions in the file:
 
```javascript
module.exports = {

  // 'VERB /route':
  // function(params) {
  //   return 'what ever you like, it will be parsed to json automatically';
  // }
  // 
  // VERB can be GET, POST, PUT, DEL but check allowHttpMethods in config.js
  // you can use params in your route, :int and :string
  // some examples: /users/:int, /users/:int/events/:int, /users_by_name/:string
  // params are then passed to the function
  // routes must start with /

  'GET /users': 
  function() {
    
    // access some vars with this
    console.log(this.db);
    
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
    return 'get all events with id ' + event_id + ' for user with id ' + user_id;
  },

  'DEL /users/:int/event_groups': 
  function(user_id) {
    return 'delete all event groups for user with id ' + user_id;
  }

};
```

Routing Algo
------------

Example: GET /users/:int

1. Get first element of request URL (users)
1. Load /controller/users.js
1. Loop over all routes found in controller:
 1. Check if HTTP method from request URL (GET) is allowed for this route (see config.allowHttpMethods)
 1. Check if HTTP method matches for this route
 1. Check if numbers of URL route elements (users, :int => 2) from request URL and this route from your controller are equal
 1. Check if route elements match (in this order: plain string, :int, :string)
 1. Break if any of these checks fail, otherwise you found your route with its function


