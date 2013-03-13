var request = require('supertest')
request = request('http://localhost:8081');

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