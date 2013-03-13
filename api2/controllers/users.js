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


module.exports = {

  'GET AUTH /users':
  // get all users
  //  likes token*
  //  returns [{id, name, email, is_admin}]
  function($) {
    $.db.query('SELECT id, name, email, is_admin ' +
      'FROM users WHERE is_disabled=0',
      function(err, results){
        if(err) return $.internalError(err);
        return $.render(results);
      }
    );
  },

  'POST AUTH /user':
  // create new user
  //  likes token*, name*, email*
  //  returns {id}
  function($) {
    var accessKey = 'secret123';
    $.db.query('INSERT INTO users SET ' +
      'name=?, email=?, password=SHA1(?), api_access_key=?',
      [$.params.name, $.params.email, $.params.email, accessKey],
      function(err, result){
        if(err) return $.internalError(err);
        return $.render({id: result.insertId});
      }
    );
  },

  'GET AUTH /user/me':
  // get user for api access key
  //  likes token*
  //  returns {id, name, email, is_admin}
  function($) {
    $.db.query('SELECT id, name, email, is_admin ' +
      'FROM users WHERE api_access_key=? LIMIT 1',
      [$.params.token],
      function(err, result){
        if(err) return $.internalError(err);
        return $.render(result[0]);
      }
    );
  },

  'GET AUTH /user/:id':
  // get user details about one user
  //  likes token*
  //  returns {id, name, email, is_admin}
  function($, user_id) {
    $.db.query('SELECT id, name, email, is_admin ' +
      'FROM users WHERE id=? LIMIT 1',
      [user_id],
      function(err, result){
        if(err) return $.internalError(err);
        return $.render(result[0]);
      }
    );
  },

  'PUT AUTH /user/:id':
  // updates a user
  //  likes token*, name*, email*
  //  returns boolean
  function($, user_id) {
    var updateFields = selectiveUpdateFields($, ['name', 'email'], [user_id]);
    if(updateFields) {
      $.db.query('UPDATE users SET ' +
        updateFields.string +
        'WHERE id=? LIMIT 1',
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

  'DELETE AUTH /user/:id':
  // delete one user
  //  likes token*
  //  returns boolean
  function($, user_id) {
    $.db.query('DELETE FROM users WHERE id=? LIMIT 1',
      [user_id],
      function(err, result){
        if(err) return $.internalError(err);
        return $.render(result.affectedRows);
      }
    );
  },

  'GET AUTH /user/:id/event_groups':
  // get all event_groups for user
  //  likes token*
  //  returns [{id, title, text}]
  function($, user_id) {
    $.db.query('SELECT event_groups.id, event_groups.title, event_groups.text ' +
      'FROM event_groups ' +
      'INNER JOIN user_has_event_groups ON user_has_event_groups.event_group_id = event_groups.id ' +
      'WHERE user_has_event_groups.user_id=?',
      [user_id],
      function(err, results){
        if(err) return $.internalError(err);
        return $.render(results);
      }
    );
  }

};