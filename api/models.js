/*
 * Models Helper File
 */
var config = require('./config.js');

module.exports = {

  get_all: function($, sql, fields, include) {
    $.db.query(sql, fields, 
      function(error, results) {
        if(error) {
          return $.error(500, 'unable to fetch results');
        } else {
          if(results.length == 0) {
            return $.error(400, 'unable to fetch result');
          }

          if(include && results.length > 0) {
            var includeKeys = Object.keys(include);
            var includeKeysLength = includeKeys.length;
            var resultsLength = results.length;

            var j = 0;
            results.forEach(function(result, j){
              j++;
              var i = 0;
              includeKeys.forEach(function(key, i){
                i++;
                var sql = include[key];
                $.db.query(sql, [ result[key + '_id'] ], function(error, subResults){
                  if(error) {
                    return $.error(500, 'unable to fetch result');
                  } else {
                    result[key] = subResults[0];
                    if(j == resultsLength && i == includeKeysLength) {
                      return $.render(results);
                    }
                  }
                });
              });

            });            
          } else {
            return $.render(results);
          }
        }
    });
  },

  post_one: function($, sql, values) {
    $.db.query(sql, values,
      function(error, results) {
        if(error) {
          return $.error(500, 'unable to create new item');
        } else {
          return $.render({"id": results.insertId});
        }
      });    
  },

  get_one: function($, id, sql, include) {

    for(var i=0; i < id.length; i++) {
      if(!id[i]) {
        return $.error(400, 'invalid parameters');
      }      
    }


    $.db.query(sql, id, 
      function(error, results) {
        if(error) {
          return $.error(500, 'unable to fetch result');
        } else {
          if(!results[0]) {
            return $.error(400, 'unable to fetch result for this id');
          }

          if(include && results[0]) {
            var includeKeys = Object.keys(include);
            var includeKeysLength = includeKeys.length;
            var i = 0;
            includeKeys.forEach(function(key, i){
              var sql = include[ key ];
              $.db.query(sql, [ results[0][key + '_id'] ], function(error, subResults){
                i++;
                if(error) {
                  return $.error(500, 'unable to fetch result');
                } else {
                  results[0][key] = subResults[0];
                  if(i == includeKeysLength) {
                    return $.render(results[0]); 
                  }
                }
              });
            });
          } else {
            return $.render(results[0]);   
          }
        }
    });
  },

  put_one: function($, id, allowFields, table, where) {
    for(var i=0; i < id.length; i++) {
      if(!id[i]) {
        return $.error(400, 'invalid parameters');
      }      
    }

    // filter $.params
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

    for(var i=0; i < id.length; i++) {
      if(!id[i]) {
        updateValues.push(id[i]);
      }      
    }
    
    $.db.query('UPDATE ' + table + ' SET ' +
      updateKeys.join(',') + ' WHERE ' + where + ' LIMIT 1',
      updateValues,
      function(error, results) {
        if(error) {
          return $.error(500, 'unable to update item');
        } else {
          return $.render({"id": id});
        }
      });    
  },

  delete_one: function($, id, table, where) {
    if(!id) {
      return $.error(400, 'invalid parameters');
    }

    $.db.query('DELETE FROM ' + table + ' WHERE ' + where + ' LIMIT 1', [id], 
      function(error, results) {
        if(error) {
          return $.error(500, 'unable to delete item');
        } else {
          return $.render({"id": id}); 
        }
    });    
  }

};



