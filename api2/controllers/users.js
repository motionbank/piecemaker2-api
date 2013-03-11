var async = require('async');

module.exports = {

  // > GET /users > json
  // > get all users
  // > curl -X GET http://localhost:8080/users
  // > curl -X GET --data "api_access_key=adklasdkd" http://localhost:8080/users // @todo  
  //
  // < 200 < json < [{"id": 1, "name": "Peter", "email": "peter@example.com", "is_admin": 0}]
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  // < 500 < json < {"http": 500, "error": "unable to fetch results"}
  'GET /users':
  function($) {
    // $.auth(function(user) {
    //   $.m.get_all($, 'SELECT * FROM users WHERE is_disabled=0');
    // });
  },

  // > POST /user > json
  // > create new user
  // > {"name": "Peter", "email": "peter@example.com", "password": "random"}
  // > curl -X POST --data "name=Matthias&email=matthias@example.com&password=12345" http://localhost:8080/user
  // 
  // < 200 < json < {"id": 1}
  // < 500 < json < {"http": 500, "error": "unable to create new item"}
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  'POST /user':
  function($) {
    // var accessKey = 'some_random_string'; // @todo
    // $.m.post_one($, 'INSERT INTO users SET name=?, email=?, password=SHA1(?), api_access_key=?', 
    //   [$.params.name, $.params.email, $.params.password, accessKey]);
  },

  'GET AUTH PENG /user/me':
  function($) {

    // console.log("$.params", $.params);

    
    // $.error(404, 'das ging daneben');
    // $.internalError('o12');


    // $.db
    // $.anyOtherHandle



    $.db.query("SELECT 1", function(err, results) {
      if(err) throw err;
      return $.render(results);
    });

    // throw new Error('ohje');

    // return $.render({hallo: 'selber!'});
    
  },

  // > GET /user/:int > json
  // > get user details about one user
  // > curl -X GET http://localhost:8080/user/1
  // 
  // < 200 < json < {"id": 1, "name": "Peter", "email": "peter@example.com"}
  // < 400 < json < {"http": 400, "error": "invalid parameters"} < means user_id from url is missing or was not found
  // < 500 < json < {"http": 500, "error": "unable to fetch result"}
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  'GET AUTH /user/:id':
  function($, user_id) {
    // $.m.get_one($, [user_id], 'SELECT id, name, email FROM users WHERE id=? LIMIT 1');
  },

  // > PUT /user/:int > json
  // > updates a user
  // > {"name": "Peter", "email": "peter@example.com"}
  // > curl -X PUT --data "email=newemail@example.com" http://localhost:8080/user/1
  // 
  // < 200 < json < {"id": 1}
  // < 400 < json < {"http": 400, "error": "invalid parameters"}
  // < 500 < json < {"http": 500, "error": "unable to update item"}
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  'PUT /user/:id':
  function($, user_id) {
    // $.m.put_one($, [user_id], ['name', 'email'], 'users', 'id=?');
  },

  // > DELETE /user/:int > json
  // > delete one user
  // > curl -X DELETE http://localhost:8080/user/3
  // 
  // < 200 < json < {"id": 1}
  // < 400 < json < {"http": 400, "error": "invalid parameters"} < user_id invalid or not found
  // < 500 < json < {"http": 500, "error": "unable to delete item"}  
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  'DELETE /user/:id':
  function($, user_id) {
    // $.m.delete_one($, user_id, 'users', 'id=?');
  },


  // > GET /user/:int/events > json
  // > get all events for user
  //
  // < 200 < json < [{"id": 1, "event_group_id": 1, "event_group": {event_group}, "created_by_user_id": 1, "created_by_user": {user}, "utc_timestamp": 0, "duration": 0}]
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  // < 500 < json < {"http": 500, "error": "unable to fetch results"}
  // 'GET /user/:int/events':
  // function($, user_id) {
  //   $.m.get_all($, 'SELECT * FROM events WHERE created_by_user_id=? ', [user_id], 
  //     {"event_group": 'SELECT id, title, text FROM event_groups WHERE id=?',
  //      "created_by_user": 'SELECT id, name, email FROM users WHERE id=?'});
  // },

  // > GET /user/:int/event_groups > json
  // > get all event_groups for user
  //
  // < 200 < json < [{"id": 1, "title": "Event Group", "text": "additional info about event group"}]
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  // < 500 < json < {"http": 500, "error": "unable to fetch results"}
  'GET /user/:id/event_groups':
  function($, user_id) {
    // $.m.get_all($, 'SELECT event_groups.* FROM event_groups INNER JOIN user_has_event_groups ON user_has_event_groups.event_group_id = event_groups.id WHERE user_has_event_groups.user_id=? ', [user_id]);
  }

};