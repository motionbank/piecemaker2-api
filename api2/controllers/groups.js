var sequence = require('sequence');
var async = require('async');
var _ = require('underscore');


// include user helper (used with .then())
var includeUser = function($, idField) {
  if(!idField) idField = 'user_id';
  var idFieldKey = idField.replace('_id', '');

  return function(next, err, model) {
    if(err) return next(err);
    if(!model) return next(new Error('invalid model'));
    
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
    if(err) return next(err);

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

var includeEventFields = function($) {
  return function(next, err, model) {
    if(err) return next(err);

    if(model instanceof Array) {
      var ids = includeHelperUniqIds(model, 'id'); // event_ids
      if(!ids || ids.length == 0) next(null, model);
      $.db.query('SELECT id, event_id, value ' +
        'FROM event_fields WHERE event_id IN (' + ids.join(',') + ')',
        function(err, results){
          if(err) return next(err);
          results = _.groupBy(results, function(elm){ return elm.event_id; })
          for(var i=0; i < model.length; i++) {
            model[i]['fields']= {};
            if(results[ model[i]['id'] ]) {
              results[ model[i]['id'] ].forEach(function(record){
                model[i]['fields'][record.id] = record.value;
              });
            }
          }
          next(null, model);
        }
      );
    } else {
      $.db.query('SELECT id, value ' +
        'FROM event_fields WHERE event_id=?',
        model['id'],
        function(err, results){
          if(err) return next(err);
          model['fields'] = {};
          results.forEach(function(record){
            model['fields'][record.id] = record.value;
          });
          next(null, model);
        }
      );
    }
  };
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


var selectiveUpdateFields = function($, posibleFields, arrayAdditional) {
  var updateFields = _.intersection(posibleFields, Object.keys($.params));
  if(updateFields.length > 0) {
    
    var string = _.map(updateFields, function(key) {
      return '`' + key + '`=?'
    });
    string = string.join(', ') + ' '; // ' ' is important

    var array = [];
    for(var i=0; i < updateFields.length; i++) {
      array.push($.params[ updateFields[i] ]);
    }

    if(!_.isArray(arrayAdditional)) {
      arrayAdditional = [arrayAdditional];
    }
    if(arrayAdditional.length > 0) {
      for(var i=0; i < arrayAdditional.length; i++) {
        array.push(arrayAdditional[i]); 
      }
    }
    return {string: string, array: array};
  }
  else {
    return false;
  }
}


var emptyParams = function($, objects) {
  if(!objects) {
    objects = $;
    // urlParams
    if(!_.isArray(objects)) objects = [objects];
    if(objects.length > 0) {
      for(var i=0; i < objects.length; i++) {
        if(_.isEmpty(objects[i])) return true;
      }
    }
  } else {
    // $.params
    if(!_.isArray(objects)) objects = [objects];
    if(objects.length > 0) {
      for(var i=0; i < objects.length; i++) {
        if(!_.has($.params, objects[i])) {
          return true;
        } else {
          if(_.isEmpty($.params[objects[i]])) return true;  
        }
      }
    }
  }
  return false;
}

var getEventGroupIdForEventField = function($, eventId, callback) {
  $.db.query('SELECT event_group_id FROM events WHERE id=? LIMIT 1', [eventId],
    function(err, result){
      if(err) return callback(err);
      if(result.length == 1 && result[0]['event_group_id']) {
        return callback(null, result[0]['event_group_id']);
      } else {
        return callback(new Error('no event found'));
      };
    });
}

var isAllowed = function($, what, id, userId, callback) {
  if(!id) return callback(new Error('invalid id'));

  sequence.create()
    .then(function(next){
      if(id['eventId']) {
        getEventGroupIdForEventField($, id['eventId'], function(err, eventId){
          if(err) return $.error(err);
          next(null, eventId);
        })
      } else {
        next(null, id['eventGroupId']);
      }
    })
    .then(function(next, err, id){
      if(_.isFunction(userId)) {
        callback = userId; 
        userId = $['api']['user']['id'] || false;
      }
      if(!userId) return callback(new Error('invalid userId'));
      $.db.query('SELECT * FROM user_has_event_groups WHERE user_id=? AND event_group_id=? LIMIT 1',
        [userId, id],
        function(err, result){
          if(err) return callback(err);
          if(result.length !== 1) return callback(new Error('invalid record'));
          return callback(null, result[0]['allow_' + what]);
        }
      );
    });

}



module.exports = {

  'GET AUTH /groups':
  // get all event_groups for current user (with read rights)
  //  likes token*
  //  returns [{id, title, text}]
  function($) {
    $.db.query('SELECT id, title, text ' +
      'FROM event_groups ' +
      'INNER JOIN user_has_event_groups ON user_has_event_groups.event_group_id=event_groups.id ' +
      'WHERE user_has_event_groups.allow_read=1',
      function(err, results){
        if(err) return $.internalError(err);
        return $.render(results);
      }
    );
  },

  'POST AUTH /group':
  // create new event_group and record for user_has_event_groups (allow everything for owner of event_group)
  //  likes token*, title*, text
  //  returns {id}
  function($) {
    if(emptyParams($, ['title'])) return $.error(400, 'missing params');

    $.db.query('INSERT INTO event_groups SET ' +
      'title=?, text=?',
      [$.params.title, $.params.text],
      function(err, result){
        if(err) return $.internalError(err);

        // create record in user_has_event_groups
        $.db.query('INSERT INTO user_has_event_groups SET ' +
          'user_id=?, event_group_id=?, allow_create=1, allow_read=1, allow_update=1, allow_delete=1',
          [$.api.user.id, result.insertId],
          function(err, _result){
            if(err) return $.internalError(err);
            return $.render({id: result.insertId});
          }
        );
      }
    );
  },

  'GET AUTH /group/:id':
  // get user details about one event_group
  //  likes token*
  //  returns {id, title, text}
  function($, event_group_id) {
    if(emptyParams(event_group_id)) return $.error(400, 'missing params');

    sequence.create()
      .then(function(next){
        isAllowed($, 'read', {eventGroupId: event_group_id}, next);        
      })
      .then(function(next, err, allowed){
        if(!allowed) return $.error(403, 'missing rights');

        $.db.query('SELECT id, title, text ' +
          'FROM event_groups WHERE id=? LIMIT 1',
          [event_group_id],
          function(err, result){
            if(err) return $.internalError(err);
            return $.render(result[0]);
          }
        );
      });
  },

  'PUT AUTH /group/:id':
  // updates a event_group
  //  likes token*, title*, text
  //  returns boolean
  function($, event_group_id) {
    if(emptyParams(event_group_id)) return $.error(400, 'missing params');
    if(emptyParams($, ['title'])) return $.error(400, 'missing params');

    sequence.create()
      .then(function(next){
        isAllowed($, 'update', {eventGroupId: event_group_id}, next);        
      })
      .then(function(next, err, allowed){
        if(!allowed) return $.error(403, 'missing rights');

        var updateFields = selectiveUpdateFields($, ['title', 'text'], event_group_id);
        if(updateFields) {
          $.db.query('UPDATE event_groups SET ' +
            updateFields.string +
            'WHERE id=? LIMIT 1',
            updateFields.array,
            function(err, result){
              if(err) return $.internalError(err);
              return $.render(result.affectedRows);
            }
          );
        } else {
          return $.error(400, 'verify update fields');
        }
      });
  },

  'DELETE AUTH /group/:id':
  // delete one event_group
  //  likes token*
  //  returns boolean
  function($, event_group_id) {
    if(emptyParams(event_group_id)) return $.error(400, 'missing params');
 
    sequence.create()
      .then(function(next){
        isAllowed($, 'delete', {eventGroupId: event_group_id}, next);        
      })
      .then(function(next, err, allowed){
        if(!allowed) return $.error(403, 'missing rights');

        $.db.query('DELETE FROM event_groups WHERE id=? LIMIT 1',
          [event_group_id],
          function(err, result){
            if(err) return $.internalError(err);
            return $.render(result.affectedRows);
          }
        );
      });
  },

  'GET AUTH /group/:id/events':
  // get all events for event_groups, add vars (utc_timestamp, duration, type and other fields from event_fields) to filter
  //  likes token*
  //  returns [{id, event_group_id, event_group, created_by_user_id, created_by_user, utc_timestamp, duration}]
  function($, event_group_id) {
    if(emptyParams(event_group_id)) return $.error(400, 'missing params');
    sequence.create()
      .then(function(next){
        isAllowed($, 'read', {eventGroupId: event_group_id}, next);        
      })
      .then(function(next, err, allowed){
        if(!allowed) return $.error(403, 'missing rights');

        sequence.create()
          .then(function(next){
            // get event
            var whereFields = [event_group_id];
            if($.params['utc_timestamp']) whereFields.push($.params['utc_timestamp']);
            if($.params['duration']) whereFields.push($.params['duration']);
            
            var eventFields = _.without(Object.keys($.params), 'token', 'utc_timestamp', 'duration');
            var eventFieldArray = [];
            for(var i=0; i < eventFields.length; i++) {
              eventFieldArray.push('(event_fields.id=' + $.db.escape(eventFields[i]) + ' AND event_fields.value=' + $.db.escape($.params[ eventFields[i] ]) + ')');
            }
      
            $.db.query('SELECT events.id, events.event_group_id, events.created_by_user_id, events.`utc_timestamp`, events.duration ' +
              'FROM events ' +
              (eventFields.length > 0 ? 'INNER JOIN event_fields ON event_fields.event_id=events.id ' : '') +
              'WHERE events.event_group_id=? ' + 
              ($.params['utc_timestamp'] ? 'AND events.`utc_timestamp`=? ' : '') + 
              ($.params['duration'] ? 'AND events.`duration`=? ' : '') + 
              (eventFields.length > 0 ? ' AND ' + eventFieldArray.join(' AND ') : ''),
              whereFields,
              function(err, results){
                if(err) return next(err);

                next(null, results);
              }
            );
          })
          .then(includeUser($, 'created_by_user_id'))
          .then(includeEventGroup($, 'event_group_id'))
          .then(includeEventFields($))
          .then(function(next, err, events){
            if(err) return $.internalError(err);
            $.render(events);
          });
      });
  },

  'GET AUTH /group/:event_group_id/event/:event_id':
  // get details about one event
  //  likes token*
  //  returns {id, event_group_id, event_group, created_by_user_id, created_by_user, utc_timestamp, duration}
  function($, event_group_id, event_id) {
    if(emptyParams([event_group_id, event_id])) return $.error(400, 'missing params');

    sequence.create()
      .then(function(next){
        isAllowed($, 'read', {eventGroupId: event_group_id}, next);        
      })
      .then(function(next, err, allowed){
        if(!allowed) return $.error(403, 'missing rights');

        sequence.create()
          .then(function(next){
            // get event
            $.db.query('SELECT id, event_group_id, created_by_user_id, `utc_timestamp`, duration ' +
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
          .then(includeEventFields($))
          .then(function(next, err, event){
            if(err) return $.internalError(err);
            $.render(event);
          });

        });
  },

  'POST AUTH /group/:event_group_id/event':
  // create new event and create new event_fields for all non-events table fields
  //  likes token*, utc_timestamp, duration, ...
  //  returns {id}
  function($, event_group_id) {
    if(emptyParams(event_group_id)) return $.error(400, 'missing params');

    sequence.create()
      .then(function(next){
        isAllowed($, 'create', {eventGroupId: event_group_id}, next);        
      })
      .then(function(next, err, allowed){
        if(!allowed) return $.error(403, 'missing rights');

        sequence.create()
        .then(function(next){
          $.db.query('START TRANSACTION', function(err){
            if(err) return next(err);
            next(null);
          })
        })
        .then(function(next){
          // insert new event
          $.db.query('INSERT INTO events SET ' +
            'event_group_id=?, created_by_user_id=?, `utc_timestamp`=?, duration=?',
            [event_group_id, $.api.user.id, $.params.utc_timestamp, $.params.duration],
            function(err, result){
              if(err) return next(err);
              next(null, result.insertId);
            }
          );
        })
        .then(function(next, err, eventId){
          // create event_fields for additonal $.params
          var ignorefields = ['token', 'id', 'event_group_id', 'created_by_user_id', 'utc_timestamp', 'duration'];
          var keys = _.difference(Object.keys($.params), ignorefields);
          async.forEach(keys, function(key, next) {
            $.db.query('INSERT INTO event_fields SET event_id=?, id=?, value=?',
              [eventId, key, $.params[key]],
              function(err, result) {
                if(err) return next(err);
                next(null)
              });
            },
            function(err){
              if(err) {
                // rollback
                $.db.query('ROLLBACK', function(err){
                  if(err) return $.internalError(err);
                  return $.render({id: eventId});
                });
              } else {
                // cool ...
                $.db.query('COMMIT', function(err){
                  if(err) return $.internalError(err);
                  return $.render({id: eventId});
                });
              }
            }
          );
        });
  
    });

  },

  'PUT AUTH /group/:event_group_id/event/:event_id':
  // updates a event
  //  likes token*, utc_timestamp, duration
  //  returns boolean
  function($, event_group_id, event_id) {
    if(emptyParams([event_group_id, event_id])) return $.error(400, 'missing params');

    sequence.create()
      .then(function(next){
        isAllowed($, 'update', {eventGroupId: event_group_id}, next);        
      })
      .then(function(next, err, allowed){
        if(!allowed) return $.error(403, 'missing rights');
    
        var updateFields = selectiveUpdateFields($, ['utc_timestamp', 'duration'], [event_group_id, event_id]);
        if(updateFields) {
          $.db.query('UPDATE events SET ' +
            updateFields.string +
            'WHERE event_group_id=? AND id=? LIMIT 1',
            updateFields.array,
            function(err, result){
              if(err) return $.internalError(err);
              return $.render(result.affectedRows);
            }
          );
        } else {
          return $.error(400, 'verify update fields');
        }

      });
  },

  'DELETE AUTH /group/:event_group_id/event/:event_id':
  // delete one event
  //  likes token*
  //  returns boolean
  function($, event_group_id, event_id) {
    if(emptyParams([event_group_id, event_id])) return $.error(400, 'missing params');

    sequence.create()
      .then(function(next){
        isAllowed($, 'delete', {eventGroupId: event_group_id}, next);        
      })
      .then(function(next, err, allowed){
        if(!allowed) return $.error(403, 'missing rights');

        $.db.query('DELETE FROM events WHERE event_group_id=? AND id=? LIMIT 1',
          [event_group_id, event_id],
          function(err, result){
            if(err) return $.internalError(err);
            return $.render(result.affectedRows);
          }
        );
      });
  },

  'GET AUTH /group/:event_group_id/events/by_type/:type':
  // get events with type 
  //  likes token*
  //  returns [{id, event_group_id, event_group, created_by_user_id, created_by_user, utc_timestamp, duration}]
  function($, event_group_id, type) {
    if(emptyParams([event_group_id, type])) return $.error(400, 'missing params');

    sequence.create()
      .then(function(next){
        isAllowed($, 'read', {eventGroupId: event_group_id}, next);        
      })
      .then(function(next, err, allowed){
        if(!allowed) return $.error(403, 'missing rights');

        sequence.create()
          .then(function(next){
            $.db.query('SELECT events.id, events.event_group_id, events.created_by_user_id, events.`utc_timestamp`, events.duration ' +
              'FROM events ' +
              'INNER JOIN event_fields ON event_fields.event_id=events.id ' +
              'WHERE events.event_group_id=? AND event_fields.id="type" AND event_fields.value=?',
              [event_group_id,type],
              function(err, results){
                if(err) return next(err);
                next(null, results);
              }
            );
          })
          .then(includeUser($, 'created_by_user_id'))
          .then(includeEventGroup($, 'event_group_id'))
          .then(includeEventFields($))
          .then(function(next, err, event){
            if(err) return $.internalError(err);
            $.render(event);
          });

      });
  },

  'GET AUTH /group/:event_group_id/users':
  // get all users for event_groups
  //  likes token*
  //  returns [{id, name, email}]
  function($, event_group_id) {
    if(emptyParams(event_group_id)) return $.error(400, 'missing params');

    sequence.create()
      .then(function(next){
        isAllowed($, 'read', {eventGroupId: event_group_id}, next);        
      })
      .then(function(next, err, allowed){
        if(!allowed) return $.error(403, 'missing rights');

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

    });
  }

};