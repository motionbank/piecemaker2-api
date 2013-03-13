var request = require('supertest')



request = request('http://localhost:8081');

describe('/users routes', function(){

  describe('GET /users.json', function(){
    it('returns all users', function(done){
    
      request
        .get('/users.json?token=123')
        .expect('Content-Type', 'application/json')
        .expect(200, {id: 2})
        .end(done);
    })
  })

})