var sequence = require('sequence');
var async = require('async');
var _ = require('underscore');


// include user helper (used with .then())
var includeUser = function($, idField) {
  if(!idField) idField = 'user_id';
  var idFieldKey = idField.replace('_id', '');

  return function(next, err, model) {
    if(model instanceof Array) {
      // include multiple users ...
      var ids = includeHelperUniqIds(model, idField);
      if(!ids || ids.length == 0) next(null, model);
      $.db.query('SELECT id, name, email, is_admin ' +
        'FROM users WHERE id IN (' + ids.join(',') + ')',
        function(err, results){
          if(err) return next(err);
          results = _.groupBy(results, function(elm){ return elm.id; })
          for(var i=0; i < model.length; i++) {
            if(results[ model[i][idField] ])
              model[i][idFieldKey] = results[ model[i][idField] ][0];
          }
          next(null, model);
        }
      );
    } else {
      // include one user ...
      $.db.query('SELECT id, name, email, is_admin ' +
        'FROM users WHERE id=? LIMIT 1',
        model[idField],
        function(err, result){
          if(err) return next(err);
          model[idFieldKey] = result[0];
          next(null, model);
        }
      );      
    }
  }     
}

// include event group helper (used with .then())
var includeEventGroup = function($, idField) {
  if(!idField) idField = 'event_group_id';
  var idFieldKey = idField.replace('_id', '');

  return function(next, err, model) {
    if(model instanceof Array) {
      // include multiple event groups ...
      var ids = includeHelperUniqIds(model, idField);
      if(!ids || ids.length == 0) next(null, model);
      $.db.query('SELECT id, title, text ' +
        'FROM event_groups WHERE id IN (' + ids.join(',') + ')',
        function(err, results){
          if(err) return next(err);
          results = _.groupBy(results, function(elm){ return elm.id; })
          for(var i=0; i < model.length; i++) {
            if(results[ model[i][idField] ])
              model[i][idFieldKey] = results[ model[i][idField] ][0];
          }
          next(null, model);
        }
      );
    } else {
      // include one event group ...
      $.db.query('SELECT id, title, text ' +
        'FROM event_groups WHERE id=? LIMIT 1',
        model[idField],
        function(err, result){
          if(err) return next(err);
          model[idFieldKey] = result[0];
          next(null, model);
        }
      );
    }
  }     
}

// extract ids from object and make ids unique ...
var includeHelperUniqIds = function(model, idField) {
  var ids = _.pluck(model, idField); // extract
  ids = _.compact(ids); // remove falsy
  ids = _.reject(ids, function(id){
    return !_.isNumber(id); // remove non-integers
  });
  ids = _.uniq(ids); // make unique
  return ids;
}





module.exports = {

  'GET AUTH /event_groups':
  // get all event_groups
  //  likes token*
  //  returns [{id, title, text}]
  function($) {
    $.db.query('SELECT id, title, text ' +
      'FROM event_groups WHERE 1',
      function(err, results){
        if(err) return $.internalError(err);
        return $.render(results);
      }
    );
  },

  'POST AUTH /event_group':
  // create new event_group
  //  likes token*, title*, text
  //  returns {id}
  function($) {
    $.db.query('INSERT INTO event_groups SET ' +
      'title=?, text=?',
      [$.params.title, $.params.text],
      function(err, result){
        if(err) return $.internalError(err);
        return $.render({id: result.insertId});
      }
    );
  },

  'GET AUTH /event_group/:id':
  // get user details about one event_group
  //  likes token*
  //  returns {id, title, text}
  function($, event_group_id) {
    $.db.query('SELECT id, title, text ' +
      'FROM event_groups WHERE id=? LIMIT 1',
      [event_group_id],
      function(err, result){
        if(err) return $.internalError(err);
        return $.render(result[0]);
      }
    );
  },

  'PUT AUTH /event_group/:id':
  // updates a event_group
  //  likes token*, title*, text
  //  returns boolean
  function($, event_group_id) {
    $.db.query('UPDATE event_groups SET ' +
      'title=?, text=? ' +
      'WHERE id=? LIMIT 1',
      [$.params.title, $.params.text, event_group_id],
      function(err, result){
        if(err) return $.internalError(err);
        return $.render(result.affectedRows);
      }
    );
  },

  'DELETE AUTH /event_group/:id':
  // delete one event_group
  //  likes token*
  //  returns boolean
  function($, event_group_id) {
    $.db.query('DELETE FROM event_groups WHERE id=? LIMIT 1',
      [event_group_id],
      function(err, result){
        if(err) return $.internalError(err);
        return $.render(result.affectedRows);
      }
    );
  },

  'GET AUTH /event_group/:id/events':
  // get all events for event_groups
  //  likes token*
  //  returns [{id, event_group_id, event_group, created_by_user_id, created_by_user, utc_timestamp, duration}]
  function($, event_group_id) {
    // @TODO $.params ?field1=value1&...
    sequence.create()
      .then(function(next){
        // get event
        $.db.query('SELECT id, event_group_id, created_by_user_id, utc_timestamp, duration ' +
          'FROM events WHERE event_group_id=?',
          [event_group_id],
          function(err, results){
            if(err) return next(err);
            next(null, results);
          }
        );
      })
      .then(includeUser($, 'created_by_user_id'))
      .then(includeEventGroup($, 'event_group_id'))
      .then(function(next, err, events){
        if(err) return $.internalError(err);
        $.render(events);
      });
  },

  'GET AUTH /event_group/:event_group_id/event/:event_id':
  // get details about one event
  //  likes token*
  //  returns {id, event_group_id, event_group, created_by_user_id, created_by_user, utc_timestamp, duration}
  function($, event_group_id, event_id) {
    sequence.create()
      .then(function(next){
        // get event
        $.db.query('SELECT id, event_group_id, created_by_user_id, utc_timestamp, duration ' +
          'FROM events WHERE event_group_id=? AND id=? LIMIT 1',
          [event_group_id, event_id],
          function(err, result){
            if(err) return next(err);
            next(null, result[0]);
          }
        );
      })
      .then(includeUser($, 'created_by_user_id'))
      .then(includeEventGroup($, 'event_group_id'))
      .then(function(next, err, event){
        if(err) return $.internalError(err);
        $.render(event);
      });
  },

  'POST AUTH /event_group/:event_group_id/event':
  // create new event and create new event_fields for all non-events table fields
  //  likes token*, event_group_id, created_by_user_id, utc_timestamp, duration, ...
  //  returns {id}
  function($, event_group_id) {
    sequence.create()
    .then(function(next){
      // insert new event
      $.db.query('INSERT INTO events SET ' +
        'event_group_id=?, created_by_user_id=?, `utc_timestamp`=?, duration=?',
        [event_group_id, $.params.created_by_user_id, $.params.utc_timestamp, $.params.duration],
        function(err, result){
          if(err) return next(err);
          next(null, result.insertId);
        }
      );
    })
    .then(function(next, err, eventId){
      // create event_fields for additonal $.params
      var ignorefields = ['id', 'event_group_id', 'created_by_user_id', 'utc_timestamp', 'duration'];
      var keys = _.difference(Object.keys($.params), ignorefields);
      $.async.forEach(keys, function(key, next) {
        $.db.query('INSERT INTO event_fields SET event_id=?, id=?, value=?',
          [eventId, key, $.params[key]],
          function(err, result) {
            if(err) return next(err);
            next(null)
          }
        );
      },
      function(err){
        if(err) {
          // rollback
        } else {
          // cool ...
        }
      });
    });
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

  'GET /event_group/:event_group_id/users':
  // get all users for event_groups
  //  likes token*
  //  returns [{id, name, email}]
  function($, event_group_id) {
    $.db.query('SELECT users.id, users.name, users.email ' +
      'FROM users ' +
      'INNER JOIN user_has_event_groups ON user_has_event_groups.user_id = users.id ' + 
      'WHERE user_has_event_groups.event_group_id=?',
      [event_group_id],
      function(err, results){
        if(err) return $.internalError(err);
        return $.render(results);
      }
    );
  }

};