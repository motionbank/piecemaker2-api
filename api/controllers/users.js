module.exports = {

  // curl -X GET http://localhost:8080/users
  'GET /users':
  function(api) {
    api.db.query('SELECT * FROM users WHERE 1', 
      function(error, results) {
        if(error) {
          api.error(error);
          return;
        } else {
          api.render(results);
        }
    });
  },

  // curl -X POST --data "name=Matthias&email=matthias@example.com&password=12345" http://localhost:8080/user
  'POST /user':
  function(api) {
    var apiAccessKey = 'some_random_string'; // @todo
    api.db.query('INSERT INTO users SET ' +
      'name=?, email=?, password=SHA1(?), api_access_key=?',
      [api.params.name, api.params.email, api.params.password, apiAccessKey],
      function(error, results) {
        if(error) {
          api.error(error);
          return;
        } else {
          api.render(results.insertId);
        }
      });
  },

  // curl -X GET http://localhost:8080/user/1
  'GET /user/:int':
  function(api, user_id) {
    if(!user_id) {
      api.error('invalid user_id');
      return;
    }

    api.db.query('SELECT * FROM users WHERE id=? LIMIT 1', [user_id], 
      function(error, results) {
        if(error) {
          api.error(error);
          return;
        } else {
          api.render(results[0] || 'false'); 
        }
    });
  },

  // curl -X PUT --data "email=newemail@example.com" http://localhost:8080/user/1
  'PUT /user/:int':
  function(api, user_id) {
    if(!user_id) {
      api.error('invalid user_id');
      return;
    }

    // filter api.params
    var allowFields = ['name', 'email'];
    var updateKeys = [];
    var updateValues = [];
    var apiParamsKeys = Object.keys(api.params);
    var apiParamsKeysLength = apiParamsKeys.length;
    for(var i=0; i < apiParamsKeysLength; i++) {
      if(~allowFields.indexOf(apiParamsKeys[i])) {
        updateKeys.push(apiParamsKeys[i] + '=?');
        updateValues.push(api.params[apiParamsKeys[i]]);
      }
    }

    updateValues.push(user_id);
    api.db.query('UPDATE users SET ' +
      updateKeys.join(',') + ' WHERE id=? LIMIT 1',
      updateValues,
      function(error, results) {
        if(error) {
          api.error(error);
          return;
        } else {
          api.db.query('SELECT * FROM users WHERE id=? LIMIT 1', [user_id], 
            function(error, results) {
              if(error) {
                api.error(error);
                return;
              } else {
                api.render(results[0] || 'false'); 
              }
          });
        }
      });
  },

  // curl -X DELETE http://localhost:8080/user/3
  'DELETE /user/:int':
  function(api, user_id) {
    if(!user_id) {
      api.error('invalid user_id');
      return;
    }

    api.db.query('DELETE FROM users WHERE id=? LIMIT 1', [user_id], 
      function(error, results) {
        if(error) {
          api.error(error);
          return;
        } else {
          api.render(user_id); 
        }
    });
  }

};
