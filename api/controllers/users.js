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

var isAdmin = function($, userId, callback) {

  if(_.isFunction(userId)) {
    // use current logged in user
    callback = userId;
    try {
      userId = $.api.user.id;  
      callback(null, $.api.user.is_admin == true);
    } catch(e) {
      return callback(new Error('no user is logged in'));
    }
  } else {
    // use userId from function call
    if(!userId) {
      return callback(new Error('no userId given'));
    }

    // get is_admin for userId
    $.db.query('SELECT is_admin FROM users WHERE id=? AND is_disabled=0 LIMIT 1',
      [userId],
      function(err, result){
        if(err) return callback(err);
        if(result.length === 1) {
          callback(null, result[0].is_admin == true);
        } else {
          return callback(null, false);
        }
      }
    );  
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
  // create new user (requires user with is_admin=1)
  //  likes token*, name*, email*
  //  returns {id}
  function($) {
    if(emptyParams($, ['name', 'email'])) return $.error(400, 'missing params');

    isAdmin($, function(err, bool){
      if(!bool) return $.error(403, 'no admin');

      var accessKey = 'secret123';
      $.db.query('INSERT INTO users SET ' +
        'name=?, email=?, password=SHA1(?), api_access_key=?',
        [$.params.name, $.params.email, $.params.email, accessKey],
        function(err, result){
          if(err) return $.internalError(err);
          return $.render({id: result.insertId});
        }
      );
    });
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
    if(emptyParams(user_id)) return $.error(400, 'missing params');

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
  // updates user details (user with is_admin=1 can update every user)
  //  likes token*, name*, email*
  //  returns boolean
  function($, user_id) {
    if(emptyParams(user_id)) return $.error(400, 'missing params');
    if(emptyParams($, ['name', 'email'])) return $.error(400, 'missing params');

    isAdmin($, function(err, bool){
      if(!bool && user_id != $.api.user.id) return $.error(402, 'no admin');

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


    });


  },

  'DELETE AUTH /user/:id':
  // delete user (user with is_admin=1 can delete every user)
  //  likes token*
  //  returns boolean
  function($, user_id) {
    if(emptyParams(user_id)) return $.error(400, 'missing params');

    isAdmin($, function(err, bool){
      if(!bool && user_id != $.api.user.id) return $.error(402, 'no admin');

      $.db.query('DELETE FROM users WHERE id=? LIMIT 1',
        [user_id],
        function(err, result){
          if(err) return $.internalError(err);
          return $.render(result.affectedRows);
        }
      );

    });
  },

  'GET AUTH /user/:id/event_groups':
  // get all event_groups for user
  //  likes token*
  //  returns [{id, title, text}]
  function($, user_id) {
    if(emptyParams(user_id)) return $.error(400, 'missing params');

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