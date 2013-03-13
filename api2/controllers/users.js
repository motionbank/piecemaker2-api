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
    $.db.query('UPDATE users SET ' +
      'name=?, email=? ' +
      'WHERE id=? LIMIT 1',
      [$.params.name, $.params.email, user_id],
      function(err, result){
        if(err) return $.internalError(err);
        return $.render(result.affectedRows);
      }
    );
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