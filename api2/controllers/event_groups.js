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
    // $.m.get_all($, 'SELECT * FROM event_groups WHERE 1');
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
    // $.m.post_one($, 'INSERT INTO event_groups SET title=?, text=?', 
    //   [$.params.title, $.params.text]);
  },

  // > GET /event_group/:int > json
  // > get user details about one event_group
  // > curl -X GET http://localhost:8080/event_group/1
  // 
  // < 200 < json < {"id": 1, title": "Event Group", "text": "additional info about event group"}
  // < 400 < json < {"http": 400, "error": "invalid parameters"}
  // < 500 < json < {"http": 500, "error": "unable to fetch result"}
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  'GET /event_group/:id':
  function($, event_group_id) {
    // $.m.get_one($, [event_group_id], 'SELECT id, title, text FROM event_groups WHERE id=? LIMIT 1');
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
  'PUT /event_group/:id':
  function($, event_group_id) {
    // $.m.put_one($, [event_group_id], ['title', 'text'], 'event_groups', 'id=?');
  },

  // > DELETE /event_group/:int > json
  // > delete one event_group
  // > curl -X DELETE http://localhost:8080/event_group/1
  // 
  // < 200 < json < {"id": 1}
  // < 400 < json < {"http": 400, "error": "invalid parameters"}
  // < 500 < json < {"http": 500, "error": "unable to delete item"}  
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  'DELETE /event_group/:id':
  function($, event_group_id) {
    // $.m.delete_one($, event_group_id, 'event_groups', 'id=?');
  },






  // > GET /event_group/:int/events > json
  // > get all events for event_groups
  // > curl -X GET http://localhost:8080/event_group/1/events
  //
  // < 200 < json < [{"id": 1, "event_group_id": 1, "event_group": {event_group}, "created_by_user_id": 1, "created_by_user": {user}, "utc_timestamp": 0, "duration": 0}]
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  // < 500 < json < {"http": 500, "error": "unable to fetch results"}
  'GET AUTH /event_group/:id/events':
  function($, event_group_id) {


    // @TODO 
    // GET /event_group/:int/events?field1=value1&field2=value2

    // $.m.get_all($, 'SELECT * FROM events WHERE event_group_id=? ', [event_group_id], 
    //   {"event_group": 'SELECT id, title, text FROM event_groups WHERE id=?',
    //    "created_by_user": 'SELECT id, name, email FROM users WHERE id=?'});
  },


  // > GET /event_group/:int/event/:int > json
  // > get details about one event
  // > curl -X GET http://localhost:8080/event/3333
  // 
  // < 200 < json < {"id": 1, "event_group_id": 1, "event_group": {event_group}, "created_by_user_id": 1, "created_by_user": {user}, "utc_timestamp": 0, "duration": 0}
  // < 400 < json < {"http": 400, "error": "invalid parameters"}
  // < 500 < json < {"http": 500, "error": "unable to fetch result"}
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  'GET /event_group/:event_group_id/event/:event_id':
  function($, event_group_id, event_id) {
    //$.m.get_one($, [event_group_id, event_id], 'SELECT * FROM events WHERE id=? AND event_group_id=? LIMIT 1', 
    //  {"event_group": 'SELECT id, title, text FROM event_groups WHERE id=?',
    //   "created_by_user": 'SELECT id, name, email FROM users WHERE id=?'});
  },


  // > POST /event_group/:int/event > json
  // > create new event, create new event_fields for all non-events table fields
  // > {"event_group_id": 1, "created_by_user_id": 1, "utc_timestamp": 0, "duration": 0}
  // > curl -X POST --data "event_group_id=3&utc_timestamp=1359834314121&duration=2&type=marker&test_custom_attr=foo" http://localhost:8080/event
  // 
  // < 200 < json < {"id": 1}
  // < 200 < json < {"id": 1, "event_fields": ["id1", "id2"]}
  // < 500 < json < {"http": 500, "error": "unable to create new item"}
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  'POST /event_group/:event_group_id/event':
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

  // > PUT /event_group/:int/event/:int > json
  // > updates a event
  // > {"event_group_id": 1, "created_by_user_id": 1, "utc_timestamp": 0, "duration": 0}
  // > curl -X PUT --data "event_group_id=3&utc_timestamp=1359834314121&duration=2&type=marker&test_custom_attr=foo" http://localhost:8080/event/8315
  // 
  // < 200 < json < {"id": 1}
  // < 400 < json < {"http": 400, "error": "invalid parameters"}
  // < 500 < json < {"http": 500, "error": "unable to update item"}
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  'PUT /event_group/:event_group_id/event/:event_id':
  function($, event_group_id, event_id) {
    // $.m.put_one($, [event_id, event_group_id], ['created_by_user_id', '`utc_timestamp`', 'duration'], 'events', 'id=? AND event_group_id=?');
  },

  // > DELETE /event_group/:int/event/:int > json
  // > delete one event
  // > curl -X DELETE http://localhost:8080/event/3333
  // 
  // < 200 < json < {"id": 1}
  // < 400 < json < {"http": 400, "error": "invalid parameters"} < user_id invalid or not found
  // < 500 < json < {"http": 500, "error": "unable to delete item"}  
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  'DELETE /event_group/:event_group_id/event/:event_id':
  function($, event_group_id, event_id) {
    // $.m.delete_one($, [event_id, event_group_id], 'events', 'id=? AND event_group_id=?');
  },


  // > GET /event_group/:int/events/type/:string > json
  // > get events with type 
  // > curl -X GET http://localhost:8080/events/type/marker
  // 
  // < 200 < json < {"id": 1, "event_group_id": 1, "event_group": {event_group}, "created_by_user_id": 1, "created_by_user": {user}, "utc_timestamp": 0, "duration": 0}
  // < 400 < json < {"http": 400, "error": "invalid parameters"}
  // < 500 < json < {"http": 500, "error": "unable to fetch result"}
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  'GET /event_group/:event_group_id/events/type/:type':
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


  // > GET /event_group/:int/users > json
  // > get all users for event_groups
  // > curl -X GET http://localhost:8080/event_group/1/users
  //
  // < 200 < json < [{"id": 1, "name": "Peter", "email": "peter@example.com"}]
  // < 401 < json < {"http": 401, "error": "unauthorized"}
  // < 500 < json < {"http": 500, "error": "unable to fetch results"}
  'GET /event_group/:event_group_id/users':
  function($, event_group_id) {
    // $.m.get_all($, 'SELECT users.id, users.name, users.email FROM users INNER JOIN user_has_event_groups ON user_has_event_groups.user_id = users.id WHERE user_has_event_groups.event_group_id=? ', [event_group_id]);
  }

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


};