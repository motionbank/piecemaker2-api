module.exports = {


  // > GET /events > json
  // > get all events
  //
  // < 200 < json < [{"id": 1, "event_group_id": 1, "event_group": {event_group}, "created_by_user_id": 1, "created_by_user": {user}, "utc_timestamp": 0, "duration": 0}]
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  // < 500 < json < {"http": 500, "error": "unable to fetch results"}
  'GET /events':
  function($) {
    $.m.get_all($, 'SELECT * FROM events WHERE 1', [], 
      {"event_group": 'SELECT id, title, text FROM event_groups WHERE id=?',
       "created_by_user": 'SELECT id, name, email FROM users WHERE id=?'});
  },

  // > POST /event > json
  // > create new event
  // > {"event_group_id": 1, "created_by_user_id": 1, "utc_timestamp": 0, "duration": 0}
  // 
  // < 200 < json < {"id": 1}
  // < 500 < json < {"http": 500, "error": "unable to create new item"}
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  'POST /event':
  function($) {
    $.m.post_one($, 'INSERT INTO events SET event_group_id=?, created_by_user_id=?, utc_timestamp=?, duration=?', 
      [$.params.event_group_id, $.params.created_by_user_id, $.params.utc_timestamp, $.params.duration]);
  },

  // > GET /event/:int > json
  // > get details about one event
  // 
  // < 200 < json < {"id": 1, "event_group_id": 1, "event_group": {event_group}, "created_by_user_id": 1, "created_by_user": {user}, "utc_timestamp": 0, "duration": 0}
  // < 400 < json < {"http": 400, "error": "invalid parameters"}
  // < 500 < json < {"http": 500, "error": "unable to fetch result"}
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  'GET /event/:int':
  function($, event_id) {
    $.m.get_one($, [event_id], 'SELECT * FROM events WHERE id=? LIMIT 1', 
      {"event_group": 'SELECT id, title, text FROM event_groups WHERE id=?',
       "created_by_user": 'SELECT id, name, email FROM users WHERE id=?'});
  },

  // > PUT /event/:int > json
  // > updates a event
  // > {"event_group_id": 1, "created_by_user_id": 1, "utc_timestamp": 0, "duration": 0}
  // 
  // < 200 < json < {"id": 1}
  // < 400 < json < {"http": 400, "error": "invalid parameters"}
  // < 500 < json < {"http": 500, "error": "unable to update item"}
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  'PUT /event/:int':
  function($, event_id) {
    $.m.put_one($, [event_id], ['event_group_id', 'created_by_user_id', 'utc_timestamp', 'duration'], 'events', 'id=?');
  },

  // > DELETE /event/:int > json
  // > delete one event
  // 
  // < 200 < json < {"id": 1}
  // < 400 < json < {"http": 400, "error": "invalid parameters"} < user_id invalid or not found
  // < 500 < json < {"http": 500, "error": "unable to delete item"}  
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  'DELETE /event/:int':
  function($, event_id) {
    $.m.delete_one($, event_id, 'events', 'id=?');
  },


  // > GET /event/:int/fields > json
  // > get fields for event
  // 
  // < 200 < json < {"id": "key", "value": "value for key"}
  // < 400 < json < {"http": 400, "error": "invalid parameters"}
  // < 500 < json < {"http": 500, "error": "unable to fetch result"}
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  'GET /event/:int/fields':
  function($, event_id) {
    $.m.get_one($, [event_id], 'SELECT id, value FROM event_fields WHERE id=? LIMIT 1');
  },


  // > POST /event/:int/field > json
  // > create new field for event
  // > {"id": "key", "value": "value for key"}
  // 
  // < 200 < json < {"id": "key"}
  // < 500 < json < {"http": 500, "error": "unable to create new item"}
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  'POST /event/:int/field':
  function($, event_id) {
    $.m.post_one($, 'INSERT INTO event_fields SET event_id=?, id=?, value=?', 
      [event_id, $.params.id, $.params.value]);
  },

  // > GET /event/:int/field/:string > json
  // > get field for event 
  // 
  // < 200 < json < {"id": "key", "value": "value for key"}
  // < 400 < json < {"http": 400, "error": "invalid parameters"}
  // < 500 < json < {"http": 500, "error": "unable to fetch result"}
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  'GET /event/:int/field/:string':
  function($, event_id, id) {
    $.m.get_one($, [event_id, id], 'SELECT id, value FROM event_fields WHERE event_id=? AND id=? LIMIT 1');
  },  

  // > PUT /event/:int/field/:string > json
  // > updates a field for an event
  // > {"id": "key", "value": "value for key"}
  // 
  // < 200 < json < {"id": "key"}
  // < 400 < json < {"http": 400, "error": "invalid parameters"}
  // < 500 < json < {"http": 500, "error": "unable to update item"}
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  'PUT /event/:int/field/:string':
  function($, event_id, id) {
    $.m.put_one($, [event_id, id], ['id', 'value'], 'event_fields', 'event_id=? AND id=?');
  },


  // > DELETE /event/:int/field/:string > json
  // > delete one field for an event
  // 
  // < 200 < json < {"id": "key"}
  // < 400 < json < {"http": 400, "error": "invalid parameters"} < user_id invalid or not found
  // < 500 < json < {"http": 500, "error": "unable to delete item"}  
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  'DELETE /event/:int/field/:string':
  function($, event_id, id) {
    $.m.delete_one($, [event_id, id], 'event_fields', 'event_id=? AND id=?');
  },


  // > GET /events/type/:string > json
  // > get events with type 
  // 
  // < 200 < json < {"id": 1, "event_group_id": 1, "event_group": {event_group}, "created_by_user_id": 1, "created_by_user": {user}, "utc_timestamp": 0, "duration": 0}
  // < 400 < json < {"http": 400, "error": "invalid parameters"}
  // < 500 < json < {"http": 500, "error": "unable to fetch result"}
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  'GET /events/type/:string':
  function($, type) {
    $.m.get_all($, 'SELECT events.* FROM events INNER JOIN event_fields ON event_fields.event_id=events.id WHERE event_fields.id=? ', [type], 
      {"event_group": 'SELECT id, title, text FROM event_groups WHERE id=?',
       "created_by_user": 'SELECT id, name, email FROM users WHERE id=?'});
  },

  // > GET /events/between/:string/and/:string > json
  // > get events between A and B 
  // 
  // < 200 < json < {"id": 1, "event_group_id": 1, "event_group": {event_group}, "created_by_user_id": 1, "created_by_user": {user}, "utc_timestamp": 0, "duration": 0}
  // < 400 < json < {"http": 400, "error": "invalid parameters"}
  // < 500 < json < {"http": 500, "error": "unable to fetch result"}
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  'GET /events/between/:string/and/:string':
  function($, time1, time2) {
    return $.error(500, 'not yet implemented');
  }  





};