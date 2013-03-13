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


module.exports = {

  'POST AUTH /event/:event_id/field':
  // create new field for event
  //  likes token*, id*, value*
  //  returns {id}
  function($, event_id) {
    if(emptyParams(event_id)) return $.error(400, 'missing params');
    if(emptyParams($, ['id'])) return $.error(400, 'missing params');

    $.db.query('INSERT INTO event_fields SET ' +
      'event_id=?, id=?, value=?',
      [event_id, $.params.id, $.params.value],
      function(err, result){
        if(err) return $.internalError(err);
        return $.render({id: result.insertId}); // @FIXME: bug in mysql module?! its not returning insertId
      }
    );
  },

  'GET AUTH /event/:event_id/field/:field_id':
  // get one field for event 
  //  likes token*
  //  returns {value}
  function($, event_id, field_id) {
    if(emptyParams([event_id, field_id])) return $.error(400, 'missing params');

    $.db.query('SELECT value ' +
      'FROM event_fields WHERE event_id=? AND id=? LIMIT 1',
      [event_id, field_id],
      function(err, result){
        if(err) return $.internalError(err);
        return $.render(result[0]);
      }
    );
  },  

  'PUT AUTH /event/:event_id/field/:field_id':
  // updates a field for an event
  //  likes token*, value
  //  returns boolean
  function($, event_id, field_id) {
    if(emptyParams([event_id, field_id])) return $.error(400, 'missing params');

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
  },

  'DELETE AUTH /event/:event_id/field/:field_id':
  // delete one field for an event
  //  likes token*
  //  returns boolean
  function($, event_id, field_id) {
    if(emptyParams([event_id, field_id])) return $.error(400, 'missing params');

    $.db.query('DELETE FROM event_fields WHERE event_id=? AND id=? LIMIT 1',
      [event_id, field_id],
      function(err, result){
        if(err) return $.internalError(err);
        return $.render(result.affectedRows);
      }
    );
  }

}