module.exports = {


  'GET AUTH /event_groups':
  // get all event_groups
  //  likes token*
  //  returns [{id, title, text}]
  function($) {
    // $.m.get_all($, 'SELECT * FROM event_groups WHERE 1');
  },

  'POST AUTH /event_group':
  // create new event_group
  //  likes token*, title*, text
  //  returns {id}
  function($) {
    // $.m.post_one($, 'INSERT INTO event_groups SET title=?, text=?', 
    //   [$.params.title, $.params.text]);
  },

  'GET AUTH /event_group/:id':
  // get user details about one event_group
  //  likes token*
  //  returns {id, title, text}
  function($, event_group_id) {

    // $.m.get_one($, [event_group_id], 'SELECT id, title, text FROM event_groups WHERE id=? LIMIT 1');
  },

  'PUT AUTH /event_group/:id':
  // updates a event_group
  //  likes token*, title*, text
  //  returns boolean
  function($, event_group_id) {
    // $.m.put_one($, [event_group_id], ['title', 'text'], 'event_groups', 'id=?');
  },

  'DELETE AUTH /event_group/:id':
  // delete one event_group
  //  likes token*
  //  returns boolean
  function($, event_group_id) {
    // $.m.delete_one($, event_group_id, 'event_groups', 'id=?');
  },

  'GET AUTH AUTH /event_group/:id/events':
  // get all events for event_groups
  //  likes token*
  //  returns [{id, event_group_id, event_group, created_by_user_id, created_by_user, utc_timestamp, duration}]
  function($, event_group_id) {
    // @TODO 
    // GET /event_group/:int/events?field1=value1&field2=value2


    // @todo
    // > GET /events/between/:string/and/:string > json
    // > get events between A and B 
    // > curl -X GET http://localhost:8080/events/between/1298937600000/and/1304208000000
    // 
    // < 200 < json < {"id": 1, "event_group_id": 1, "event_group": {event_group}, "created_by_user_id": 1, "created_by_user": {user}, "utc_timestamp": 0, "duration": 0}
    // < 400 < json < {"http": 400, "error": "invalid parameters"}
    // < 500 < json < {"http": 500, "error": "unable to fetch result"}
    // < 401 < json < {"http": 401, "error": "unauthorized"}
    //'GET /events/between/:string/and/:string':
    //function($, time1, time2) {
    //  return $.error(500, 'not yet implemented');
    //}  


    // $.m.get_all($, 'SELECT * FROM events WHERE event_group_id=? ', [event_group_id], 
    //   {"event_group": 'SELECT id, title, text FROM event_groups WHERE id=?',
    //    "created_by_user": 'SELECT id, name, email FROM users WHERE id=?'});
  },

  'GET AUTH /event_group/:event_group_id/event/:event_id':
  // get details about one event
  //  likes token*
  //  returns {id, event_group_id, event_group, created_by_user_id, created_by_user, utc_timestamp, duration}
  function($, event_group_id, event_id) {
    //$.m.get_one($, [event_group_id, event_id], 'SELECT * FROM events WHERE id=? AND event_group_id=? LIMIT 1', 
    //  {"event_group": 'SELECT id, title, text FROM event_groups WHERE id=?',
    //   "created_by_user": 'SELECT id, name, email FROM users WHERE id=?'});
  },

  'POST AUTH /event_group/:event_group_id/event':
  // create new event, create new event_fields for all non-events table fields
  //  likes token*, event_group_id, created_by_user_id, utc_timestamp, duration
  //  returns {event_id}
  function($, event_group_id) {
    //.m.post_one($, 'INSERT INTO events SET event_group_id=?, created_by_user_id=?, `utc_timestamp`=?, duration=?', 
    // [event_group_id, $.params.created_by_user_id, $.params.utc_timestamp, $.params.duration], function(result) {

    //   // create event_fields for additonal $.params
    //   var ignorefields = ["id", "event_group_id", "created_by_user_id", "utc_timestamp", "duration"];
    //   var keys = Object.keys($.params);
    //   var successKeys = [];
    //   $.async.forEach(keys, function(key, callback) {
    //     // apply this to each item
    //     if(~ignorefields.indexOf(key)) return callback.call(null);

    //     $.db.query("INSERT INTO event_fields SET event_id=?, id=?, value=?", [result.id, key, $.params[key]],
    //       function(error, results) {
    //         if(!error) { 
    //           successKeys.push(key);
    //         }
    //         callback.call(null);
    //       });
    //   }, 
    //   function(err) {
    //     // finishing callback
    //     if(err) {
    //       return $.render(result); // event was created, no event_fields though
    //     } else {
    //       result["event_fields"] = successKeys;
    //       return $.render(result); // event was created, event_fields as well
    //     }
    //   });


    // });
  },

  'PUT AUTH /event_group/:event_group_id/event/:event_id':
  // updates a event
  //  likes token*, event_group_id, created_by_user_id, utc_timestamp, duration
  //  returns boolean
  function($, event_group_id, event_id) {
    // $.m.put_one($, [event_id, event_group_id], ['created_by_user_id', '`utc_timestamp`', 'duration'], 'events', 'id=? AND event_group_id=?');
  },

  'DELETE AUTH /event_group/:event_group_id/event/:event_id':
  // delete one event
  //  likes token*
  //  returns boolean
  function($, event_group_id, event_id) {
    // $.m.delete_one($, [event_id, event_group_id], 'events', 'id=? AND event_group_id=?');
  },

  'GET AUTH /event_group/:event_group_id/events/type/:type':
  // get events with type 
  //  likes token*
  //  returns [{id, event_group_id, event_group, created_by_user_id, created_by_user, utc_timestamp, duration}]
  function($, event_group_id, type) {
    // $.m.get_all($, 'SELECT events.* FROM events INNER JOIN event_fields ON event_fields.event_id=events.id WHERE events.event_group_id=? AND event_fields.id=? AND event_fields.value=? ', [event_group_id,'type',type], 
    //   {"event_group": 'SELECT id, title, text FROM event_groups WHERE id=?',
    //    "created_by_user": 'SELECT id, name, email FROM users WHERE id=?'},
    //    function(results){
    //     // get event fields and add them
    //     $.async.forEach(results, 
    //       function(result, callback){
// 
    //         $.db.query('SELECT id, value FROM event_fields WHERE event_id=?', [result.id], 
    //           function(error, results) {
    //             if(!error) {
    //               result['event_fields'] = results;
    //             }
    //             callback.call(null);
    //           });
    //       },
    //       function(error){
    //         return $.render(results);
    //       }
    //     );
// 
    //    });
  },

  'GET AUTH /event_group/:event_group_id/users':
  // get all users for event_groups
  //  likes token*
  //  returns [{id, name, email}]
  function($, event_group_id) {
    // $.m.get_all($, 'SELECT users.id, users.name, users.email FROM users INNER JOIN user_has_event_groups ON user_has_event_groups.user_id = users.id WHERE user_has_event_groups.event_group_id=? ', [event_group_id]);
  }

};