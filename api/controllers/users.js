module.exports = {

  // > GET /users > json
  // > get all users
  // > curl -X GET http://localhost:8080/users
  //
  // < 200 < json < [{"id": 1, "name": "Peter", "email": "peter@example.com", "is_admin": 0}]
  // < 401 < json < {"error": 401, "message": "unauthorized"}
  'GET /users':
  function($) {
    $.db.query('SELECT * FROM users WHERE is_disabled=0', 
      function(error, results) {
        if(error) {
          return $.error(500, error);
        } else {
          return $.render(results);
        }
    });
  },


  // > POST /user > json
  // > create new user
  // > {"name": "Peter", "email": "peter@example.com", "password": "random"}
  // > curl -X POST --data "name=Matthias&email=matthias@example.com&password=12345" http://localhost:8080/user
  // 
  // < 200 < json < {"id": 1}
  // < 400 < json < {"error": 400, "message": "invalid parameters"}
  // < 401 < json < {"error": 401, "message": "unauthorized"}
  'POST /user':
  function($) {
    var $AccessKey = 'some_random_string'; // @todo
    $.db.query('INSERT INTO users SET ' +
      'name=?, email=?, password=SHA1(?), $_access_key=?',
      [$.params.name, $.params.email, $.params.password, $AccessKey],
      function(error, results) {
        if(error) {
          return $.error(400, error);
        } else {
          return $.render(results.insertId);
        }
      });
  },

  // > GET /user/:int > json
  // > get user details about one user
  // > curl -X GET http://localhost:8080/user/1
  // 
  // < 200 < json < {"id": 1, "name": "Peter", "email": "peter@example.com"}
  // < 400 < json < {"error": 400, "message": "invalid parameters"} < means user_id from url is missing or was not found
  // < 401 < json < {"error": 401, "message": "unauthorized"}
  'GET /user/:int':
  function($, user_id) {
    if(!user_id) {
      return $.error('invalid user_id');
    }

    $.db.query('SELECT * FROM users WHERE isd=? LIMIT 1', [user_id], 
      function(error, results) {
        if(error) {
          return $.error(400, 'invalid parameters');
        } else {
          return $.render(results[0] || 'false'); 
        }
    });
  },


  // > PUT /user/:int > json
  // > updates a user
  // > {"name": "Peter", "email": "peter@example.com"}
  // > curl -X PUT --data "email=newemail@example.com" http://localhost:8080/user/1
  // 
  // < 200 < json < {"id": 1, "name": "Peter", "email": "peter@example.com"}
  // < 400 < json < {"error": 400, "message": "invalid parameters"}
  // < 401 < json < {"error": 401, "message": "unauthorized"}
  'PUT /user/:int':
  function($, user_id) {
    if(!user_id) {
      return $.error(400, 'invalid user_id');
    }

    // filter $.params
    var allowFields = ['name', 'email'];
    var updateKeys = [];
    var updateValues = [];
    var $ParamsKeys = Object.keys($.params);
    var $ParamsKeysLength = $ParamsKeys.length;
    for(var i=0; i < $ParamsKeysLength; i++) {
      if(~allowFields.indexOf($ParamsKeys[i])) {
        updateKeys.push($ParamsKeys[i] + '=?');
        updateValues.push($.params[$ParamsKeys[i]]);
      }
    }

    // anything to update?
    if(updateKeys.length == 0) {
      return $.render('false');
    }

    updateValues.push(user_id);
    $.db.query('UPDATE users SET ' +
      updateKeys.join(',') + ' WHERE id=? LIMIT 1',
      updateValues,
      function(error, results) {
        if(error) {
          return$.error(error);
        } else {
          $.db.query('SELECT * FROM users WHERE id=? LIMIT 1', [user_id], 
            function(error, results) {
              if(error) {
                return $.error(error);
              } else {
                return $.render(results[0] || 'false'); 
              }
          });
        }
      });
  },

  // > DELETE /user/:int > json
  // > delete one user
  // > curl -X DELETE http://localhost:8080/user/3
  // 
  // < 200 < json < {"id": 1}
  // < 400 < json < {"error": 400, "message": "invalid parameters"} < user_id invalid or not found
  // < 401 < json < {"error": 401, "message": "unauthorized"}
  'DELETE /user/:int':
  function($, user_id) {
    if(!user_id) {
      return $.error('invalid user_id');
    }

    $.db.query('DELETE FROM users WHERE id=? LIMIT 1', [user_id], 
      function(error, results) {
        if(error) {
          return $.error(error);
        } else {
          return $.render(user_id); 
        }
    });
  }

};
