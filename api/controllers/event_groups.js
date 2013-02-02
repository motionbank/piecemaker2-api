module.exports = {

  // > GET /event_groups > json
  // > get all event_groups
  // > curl -X GET http://localhost:8080/event_groups
  //
  // < 200 < json < [{"id": 1, "title": "Event Group", "text": "additional info about event group"}]
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  // < 500 < json < {"http": 500, "error": "unable to fetch results"}
  'GET /event_groups':
  function($) {
    $.m.get_all($, 'SELECT * FROM event_groups WHERE 1');
  },

  // > POST /event_group > json
  // > create new event_group
  // > {title": "Event Group", "text": "additional info about event group"}
  // > curl -X POST --data "title=Test group&text=This is just an example test group" http://localhost:8080/event_group
  // 
  // < 200 < json < {"id": 1}
  // < 500 < json < {"http": 500, "error": "unable to create new item"}
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  'POST /event_group':
  function($) {
    $.m.post_one($, 'INSERT INTO event_groups SET title=?, text=?', 
      [$.params.title, $.params.text]);
  },

  // > GET /event_group/:int > json
  // > get user details about one event_group
  // > curl -X GET http://localhost:8080/event_group/1
  // 
  // < 200 < json < {"id": 1, title": "Event Group", "text": "additional info about event group"}
  // < 400 < json < {"http": 400, "error": "invalid parameters"}
  // < 500 < json < {"http": 500, "error": "unable to fetch result"}
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  'GET /event_group/:int':
  function($, event_group_id) {
    $.m.get_one($, [event_group_id], 'SELECT id, title, text FROM event_groups WHERE id=? LIMIT 1');
  },

  // > PUT /event_group/:int > json
  // > updates a event_group
  // > {title": "Event Group", "text": "additional info about event group"}
  // > curl -X PUT --data "title=Testgroup updated&text=This test group has been updated!" http://localhost:8080/event_group/2
  // 
  // < 200 < json < {"id": 1}
  // < 400 < json < {"http": 400, "error": "invalid parameters"}
  // < 500 < json < {"http": 500, "error": "unable to update item"}
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  'PUT /event_group/:int':
  function($, event_group_id) {
    $.m.put_one($, [event_group_id], ['title', 'text'], 'event_groups', 'id=?');
  },

  // > DELETE /event_group/:int > json
  // > delete one event_group
  // > curl -X DELETE http://localhost:8080/event_group/1
  // 
  // < 200 < json < {"id": 1}
  // < 400 < json < {"http": 400, "error": "invalid parameters"}
  // < 500 < json < {"http": 500, "error": "unable to delete item"}  
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  'DELETE /event_group/:int':
  function($, event_group_id) {
    $.m.delete_one($, event_group_id, 'event_groups', 'id=?');
  },

  // > GET /event_group/:int/events > json
  // > get all events for event_groups
  // > curl -X GET http://localhost:8080/event_group/1/events
  //
  // < 200 < json < [{"id": 1, "event_group_id": 1, "event_group": {event_group}, "created_by_user_id": 1, "created_by_user": {user}, "utc_timestamp": 0, "duration": 0}]
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  // < 500 < json < {"http": 500, "error": "unable to fetch results"}
  'GET /event_group/:int/events':
  function($, event_group_id) {
    $.m.get_all($, 'SELECT * FROM events WHERE event_group_id=? ', [event_group_id], 
      {"event_group": 'SELECT id, title, text FROM event_groups WHERE id=?',
       "created_by_user": 'SELECT id, name, email FROM users WHERE id=?'});
  },

  // > GET /event_group/:int/users > json
  // > get all users for event_groups
  // > curl -X GET http://localhost:8080/event_group/1/users
  //
  // < 200 < json < [{"id": 1, "name": "Peter", "email": "peter@example.com"}]
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  // < 500 < json < {"http": 500, "error": "unable to fetch results"}
  'GET /event_group/:int/users':
  function($, event_group_id) {
    $.m.get_all($, 'SELECT users.id, users.name, users.email FROM users INNER JOIN user_has_event_groups ON user_has_event_groups.user_id = users.id WHERE user_has_event_groups.event_group_id=? ', [event_group_id]);
  }

};
