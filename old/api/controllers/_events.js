module.exports = {


  // > GET /events > json
  // > get all events
  // > curl -X GET http://localhost:8080/events
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
  // > create new event, create new event_fields for all non-events table fields
  // > {"event_group_id": 1, "created_by_user_id": 1, "utc_timestamp": 0, "duration": 0}
  // > curl -X POST --data "event_group_id=3&utc_timestamp=1359834314121&duration=2&type=marker&test_custom_attr=foo" http://localhost:8080/event
  // 
  // < 200 < json < {"id": 1}
  // < 200 < json < {"id": 1, "event_fields": ["id1", "id2"]}
  // < 500 < json < {"http": 500, "error": "unable to create new item"}
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  'POST /event':
  function($) {
    $.m.post_one($, 'INSERT INTO events SET event_group_id=?, created_by_user_id=?, `utc_timestamp`=?, duration=?', 
      [$.params.event_group_id, $.params.created_by_user_id, $.params.utc_timestamp, $.params.duration], function(result) {

        // create event_fields for additonal $.params
        var ignorefields = ["id", "event_group_id", "created_by_user_id", "utc_timestamp", "duration"];
        var keys = Object.keys($.params);
        var successKeys = [];
        $.async.forEach(keys, function(key, callback) {
          // apply this to each item
          if(~ignorefields.indexOf(key)) return callback.call(null);

          $.db.query("INSERT INTO event_fields SET event_id=?, id=?, value=?", [result.id, key, $.params[key]],
            function(error, results) {
              if(!error) { 
                successKeys.push(key);
              }
              callback.call(null);
            });
        }, 
        function(err) {
          // finishing callback
          if(err) {
            return $.render(result); // event was created, no event_fields though
          } else {
            result["event_fields"] = successKeys;
            return $.render(result); // event was created, event_fields as well
          }
        });


      });



  },

  // > GET /event/:int > json
  // > get details about one event
  // > curl -X GET http://localhost:8080/event/3333
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
  // > curl -X PUT --data "event_group_id=3&utc_timestamp=1359834314121&duration=2&type=marker&test_custom_attr=foo" http://localhost:8080/event/8315
  // 
  // < 200 < json < {"id": 1}
  // < 400 < json < {"http": 400, "error": "invalid parameters"}
  // < 500 < json < {"http": 500, "error": "unable to update item"}
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  'PUT /event/:int':
  function($, event_id) {
    $.m.put_one($, [event_id], ['event_group_id', 'created_by_user_id', '`utc_timestamp`', 'duration'], 'events', 'id=?');
  },

  // > DELETE /event/:int > json
  // > delete one event
  // > curl -X DELETE http://localhost:8080/event/3333
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
  // > curl -X GET http://localhost:8080/event/3333/fields
  // 
  // < 200 < json < {"id": "key", "value": "value for key"}
  // < 400 < json < {"http": 400, "error": "invalid parameters"}
  // < 500 < json < {"http": 500, "error": "unable to fetch result"}
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  'GET /event/:int/fields':
  function($, event_id) {
    $.m.get_all($, 'SELECT id, value FROM event_fields WHERE event_id=?', [event_id]);
  },


  // > POST /event/:int/field > json
  // > create new field for event
  // > {"id": "key", "value": "value for key"}
  // > curl -X POST --data "id=custom&value=komischer Wert ohne Sinn hier" http://localhost:8080/event/3333/field
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
  // > curl -X GET http://localhost:8080/event/8314/field/custom
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
  // > curl -X PUT --data "value=ein anderer Wert hier" http://localhost:8080/event/8314/field/custom
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
  // > curl -X DELETE http://localhost:8080/event/8314/field/custom
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
  // > curl -X GET http://localhost:8080/events/type/marker
  // 
  // < 200 < json < {"id": 1, "event_group_id": 1, "event_group": {event_group}, "created_by_user_id": 1, "created_by_user": {user}, "utc_timestamp": 0, "duration": 0}
  // < 400 < json < {"http": 400, "error": "invalid parameters"}
  // < 500 < json < {"http": 500, "error": "unable to fetch result"}
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  'GET /events/type/:string':
  function($, type) {
    $.m.get_all($, 'SELECT events.* FROM events INNER JOIN event_fields ON event_fields.event_id=events.id WHERE event_fields.id=? AND event_fields.value=? ', ['type',type], 
      {"event_group": 'SELECT id, title, text FROM event_groups WHERE id=?',
       "created_by_user": 'SELECT id, name, email FROM users WHERE id=?'},
       function(results){
        // get event fields and add them
        $.async.forEach(results, 
          function(result, callback){

            $.db.query('SELECT id, value FROM event_fields WHERE event_id=?', [result.id], 
              function(error, results) {
                if(!error) {
                  result['event_fields'] = results;
                }
                callback.call(null);
              });
          },
          function(error){
            return $.render(results);
          }
        );

       });
  },

  // > GET /events/between/:string/and/:string > json
  // > get events between A and B 
  // > curl -X GET http://localhost:8080/events/between/1298937600000/and/1304208000000
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