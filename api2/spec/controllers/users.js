var request = require('supertest')



request = request('http://localhost:8081');

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