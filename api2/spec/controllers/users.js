var request = require('supertest')
request = request('http://localhost:8081');

describe.only('controllers/users.js', function(){


  describe('POST AUTH /user', function(){
    it('creates new user', function(done){
      request
        .post('/user.json?token=6a66515fcc6b585a69df6b50805146cf8fb91b9c')
        .send({name: 'Heinz', email: 'heinz@example.com'})
        .expect('Content-Type', 'application/json')
        .expect(200, { id: 601 })
        .end(done);
    });
  });

  describe('GET AUTH /users', function(){
    it('gets all users', function(done){
      request
        .get('/users.json?token=6a66515fcc6b585a69df6b50805146cf8fb91b9c')
        .expect('Content-Type', 'application/json')
        .expect(200, [ 
          { id: 500, name: 'Hans', email: 'hans@example.com', is_admin: 1 }, 
          { id: 600, name: 'Peter', email: 'peter@example.com', is_admin: 1 },
          { id: 601, name: 'Heinz', email: 'heinz@example.com', is_admin: 0 } ])
        .end(done);
    });
  });

  describe('GET AUTH /user/me', function(){
    it('gets user for api access key', function(done){
      request
        .get('/user/me.json?token=0acbc5bc1a0e5fc7390f4ea91500eba665998ef7')
        .expect('Content-Type', 'application/json')
        .expect(200, { id: 600, name: 'Peter', email: 'peter@example.com', is_admin: 1 } )
        .end(done);
    });
  });

  describe('PUT AUTH /user/:id', function(){
    it('updates a user', function(done){
      request
        .put('/user/601.json?token=6a66515fcc6b585a69df6b50805146cf8fb91b9c')
        .send({name: 'Heinzelmann', email: 'heinzelmann@example.com'})
        .expect('Content-Type', 'application/json')
        .expect(200, '1')
        .end(done);
    });
  });

  describe('GET AUTH /user/:id', function(){
    it('get user details about one user', function(done){
      request
        .get('/user/601.json?token=6a66515fcc6b585a69df6b50805146cf8fb91b9c')
        .expect('Content-Type', 'application/json')
        .expect(200, { id: 601, name: 'Heinzelmann', email: 'heinzelmann@example.com', is_admin: 0 } )
        .end(done);
    });
  });


  describe('DELETE AUTH /user/:id', function(){
    it('updates a user', function(done){
      request
        .del('/user/601.json?token=6a66515fcc6b585a69df6b50805146cf8fb91b9c')
        .expect('Content-Type', 'application/json')
        .expect(200, '1')
        .end(done);
    });
  });

  describe('GET AUTH /users', function(){
    it('gets all users', function(done){
      request
        .get('/users.json?token=6a66515fcc6b585a69df6b50805146cf8fb91b9c')
        .expect('Content-Type', 'application/json')
        .expect(200, [ 
          { id: 500, name: 'Hans', email: 'hans@example.com', is_admin: 1 }, 
          { id: 600, name: 'Peter', email: 'peter@example.com', is_admin: 1 } ])
        .end(done);
    });
  });


  describe('GET AUTH /user/:id/event_groups', function(){
    it('gets all event_groups for user', function(done){
      request
        .get('/user/500/event_groups.json?token=6a66515fcc6b585a69df6b50805146cf8fb91b9c')
        .expect('Content-Type', 'application/json')
        .expect(200, [ { id: 501, title: 'Event Group 1', text: 'some description' } ])
        .end(done);
    });
  });

});