var sequence = require('sequence');
var async = require('async');
var _ = require('underscore');

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

  'POST AUTH /event/:event_id/field':
  // create new field for event
  //  likes token*, id*, value*
  //  returns {id}
  function($, event_id) {
    if(emptyParams(event_id)) return $.error(400, 'missing params');
    if(emptyParams($, ['id'])) return $.error(400, 'missing params');

    sequence.create()
      .then(function(next){
        isAllowed($, 'create', {eventId: event_id}, next);        
      })
      .then(function(next, err, allowed){
        if(!allowed) return $.error(403, 'missing rights');

        $.db.query('INSERT INTO event_fields SET ' +
          'event_id=?, id=?, value=?',
          [event_id, $.params.id, $.params.value],
          function(err, result){
            if(err) return $.internalError(err);
            return $.render({id: result.insertId}); // @FIXME: bug in mysql module?! its not returning insertId
          }
        );
      })
  },

  'GET AUTH /event/:event_id/field/:field_id':
  // get one field for event 
  //  likes token*
  //  returns {value}
  function($, event_id, field_id) {
    if(emptyParams([event_id, field_id])) return $.error(400, 'missing params');

    sequence.create()
      .then(function(next){
        isAllowed($, 'read', {eventId: event_id}, next);        
      })
      .then(function(next, err, allowed){
        if(!allowed) return $.error(403, 'missing rights');

        $.db.query('SELECT value ' +
          'FROM event_fields WHERE event_id=? AND id=? LIMIT 1',
          [event_id, field_id],
          function(err, result){
            if(err) return $.internalError(err);
            return $.render(result[0]);
          }
        );
      });
  },  

  'PUT AUTH /event/:event_id/field/:field_id':
  // updates a field for an event
  //  likes token*, value
  //  returns boolean
  function($, event_id, field_id) {
    if(emptyParams([event_id, field_id])) return $.error(400, 'missing params');

    sequence.create()
      .then(function(next){
        isAllowed($, 'update', {eventId: event_id}, next);        
      })
      .then(function(next, err, allowed){
        if(!allowed) return $.error(403, 'missing rights');

        var updateFields = selectiveUpdateFields($, ['value'], [event_id, field_id]);
        if(updateFields) {
          $.db.query('UPDATE event_fields SET ' +
            updateFields.string +
            'WHERE event_id=? AND id=? LIMIT 1',
            updateFields.array,
            function(err, result){
              if(err) return $.internalError(err);
              return $.render(result.affectedRows);
            }
          );
        } else {
          $.error(400, 'verify update fields');
        }
      });
  },

  'DELETE AUTH /event/:event_id/field/:field_id':
  // delete one field for an event
  //  likes token*
  //  returns boolean
  function($, event_id, field_id) {
    if(emptyParams([event_id, field_id])) return $.error(400, 'missing params');

    sequence.create()
      .then(function(next){
        isAllowed($, 'delete', {eventId: event_id}, next);        
      })
      .then(function(next, err, allowed){
        if(!allowed) return $.error(403, 'missing rights');

        $.db.query('DELETE FROM event_fields WHERE event_id=? AND id=? LIMIT 1',
          [event_id, field_id],
          function(err, result){
            if(err) return $.internalError(err);
            return $.render(result.affectedRows);
          }
        );
      });
  }

}