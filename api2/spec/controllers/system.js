var request = require('supertest')
var config = require('../../config/test.js');
request = request('http://localhost:' + config.api.port);

describe('controllers/system.js', function(){


  describe('GET /system/utc_timestamp', function(){
    it('gets unix timestamp with milliseconds');
    /*
    it('get unix timestamp with milliseconds', function(done){
      request
        .get('/system/utc_timestamp.json')
        .expect('Content-Type', 'application/json')
        .expect(200, { id: 601 })
        .end(done);
    });
    */
  });

});