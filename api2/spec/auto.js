var request = require('supertest')
var path = require('path')
var fs = require('fs')
var _ = require('underscore')
request = request('http://localhost:8081');


return; 

// do some auto testing: see below!

// parse ...

var powertrim = function(str, leftTrim, rightTrim, skipPreTrim, skipAfterTrim) {
  if(!skipPreTrim) str = str.trim();
  if(rightTrim && str.substr(-rightTrim.length) == rightTrim)
      str = str.substr(0, str.length - rightTrim.length);
  if(leftTrim && str.indexOf(leftTrim) === 0)
    str = str.substr(leftTrim.length);
  if(!skipAfterTrim) str = str.trim();
  return str;
}

var files = fs.readdirSync('./controllers');
var filesLength = files.length;
if(filesLength > 0) {
  var routes = [];
  for(var i=0; i < filesLength; i++) {
    var filePath = path.normalize(path.resolve('./controllers') + '/' + files[i]);
    var fileName = path.basename(filePath, '.js');
    var content = fs.readFileSync(filePath, 'utf8');
    content = content.split('\n');
    if(content.length > 0) {
      var block = {};
      var newBlock = false;
      for(var j=0; j < content.length; j++) {

        if(newBlock) {
          routes.push(block);
          block = {};
          newBlock = false;
        }

        if(content[j].indexOf("  '") === 0) block['signature'] = powertrim(content[j], "'", "':");
        else if(content[j].indexOf("  //  likes ") === 0) block['likes'] = powertrim(content[j], "//  ", null);
        else if(content[j].indexOf("  //  returns ") === 0) block['returns'] = powertrim(content[j], "//  ", null);
        else if(content[j].indexOf("  // ") === 0) block['comments'] = powertrim(content[j], "// ", null);
        else if(content[j].indexOf("  function($") === 0) {
          block['urlParams'] = powertrim(powertrim(content[j], "function($", '{'), ',', ')');
          newBlock = true;
        }
      }
    }
  }

  if(routes.length > 0) {

    /* 
      'GET AUTH /users':
      // get all users
      //  likes token*
      //  returns [{id, name, email}]
      function($) {
    */

    for(var i=0; i < routes.length; i++) {
      var route = routes[i];

      // if AUTH and no token is given, expect 403 forbidden
      if(route['signature'] && ~route['signature'].indexOf('AUTH')) {

      }

      // if param* is required and not given, expect 500 error
      if(route['likes']) {
        describe('if param* is required and not given', function(){

          // filter required params
          var required = route['likes'].match(/([^ ]*)\*/ig);
          console.log(route['signature'], required);

          if(required.length > 0) {
            for(var j=0; j < required.length; j++) {
              var _required = powertrim(required[j], '', '*');

              describe(route['signature'] + '.json with missing param ' + _required, function(){
                it('should return an error', function(done){
                  request
                    .get('/users.json?token=6a66515fcc6b585a69df6b50805146cf8fb91b9c')
                    .expect('Content-Type', 'application/json')
                    .expect(200, [ { id: 500, name: 'Hans', email: 'hans@example.com', is_admin: 1 } ])
                    .end(done);
                })
              });

            }
          }

        });
      }

    }

  }
}

/*
describe('/users routes', function(){

  describe('GET /users.json', function(){
    it('returns all users', function(done){
      request
        .get('/users.json?token=6a66515fcc6b585a69df6b50805146cf8fb91b9c')
        .expect('Content-Type', 'application/json')
        .expect(200, [ { id: 500, name: 'Hans', email: 'hans@example.com', is_admin: 1 } ])
        .end(done);
    })
  })

})

*/