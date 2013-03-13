var request = require('supertest')
request = request('http://localhost:8081');

describe('controllers/groups.js', function(){

  describe('GET AUTH /groups', function(){
    it('gets all event_groups', function(done){
      request
        .get('/groups.json?token=6a66515fcc6b585a69df6b50805146cf8fb91b9c')
        .expect('Content-Type', 'application/json')
        .expect(200, [ { id: 501, title: 'Event Group 1', text: 'some description' } ])
        .end(done);
    });
  });

  describe('POST AUTH /group', function(){
    it('creates new event_group', function(done){
      request
        .post('/group.json?token=6a66515fcc6b585a69df6b50805146cf8fb91b9c')
        .send({title: 'Another Event Group', text: 'awesome stuff'})
        .expect('Content-Type', 'application/json')
        .expect(200, { id: 502 })
        .end(done);
    });
  });


  describe('GET AUTH /groups', function(){
    it('gets all event_groups', function(done){
      request
        .get('/groups.json?token=6a66515fcc6b585a69df6b50805146cf8fb91b9c')
        .expect('Content-Type', 'application/json')
        .expect(200, [ { id: 501, title: 'Event Group 1', text: 'some description' },
          { id: 502, title: 'Another Event Group', text: 'awesome stuff' } ])
        .end(done);
    });
  });

  describe('PUT AUTH /group/:id', function(){
    it('updatess a event_group', function(done){
      request
        .put('/group/502.json?token=6a66515fcc6b585a69df6b50805146cf8fb91b9c')
        .send({title: 'Changed Title', text: 'and text again'})
        .expect('Content-Type', 'application/json')
        .expect(200, '1')
        .end(done);
    });
  });


  describe('GET AUTH /group/:id', function(){
    it('gets user details about one event_group', function(done){
      request
        .get('/group/502.json?token=6a66515fcc6b585a69df6b50805146cf8fb91b9c')
        .expect('Content-Type', 'application/json')
        .expect(200, { id: 502, title: 'Changed Title', text: 'and text again' })
        .end(done);
    });
  });

  describe('DELETE AUTH /group/:id', function(){
    it('deletes one event_group', function(done){
      request
        .del('/group/502.json?token=6a66515fcc6b585a69df6b50805146cf8fb91b9c')
        .expect('Content-Type', 'application/json')
        .expect(200, '1')
        .end(done);
    });
  });


  describe('GET AUTH /groups', function(){
    it('gets all event_groups', function(done){
      request
        .get('/groups.json?token=6a66515fcc6b585a69df6b50805146cf8fb91b9c')
        .expect('Content-Type', 'application/json')
        .expect(200, [ { id: 501, title: 'Event Group 1', text: 'some description' } ])
        .end(done);
    });
  });




  describe('GET AUTH /group/:id/events', function(){
    it('gets all events for event_groups', function(done){
      request
        .get('/group/501/events.json?token=6a66515fcc6b585a69df6b50805146cf8fb91b9c')
        .expect('Content-Type', 'application/json')
        .expect(200, [ { id: 502,
          event_group_id: 501,
          created_by_user_id: 500,
          utc_timestamp: 0,
          duration: 0,
          created_by_user: { id: 500, name: 'Hans', email: 'hans@example.com', is_admin: 1 },
          event_group: { id: 501, title: 'Event Group 1', text: 'some description' } } ])
        .end(done);
    });
  });


  describe('GET AUTH /group/:event_group_id/event/:event_id', function(){
    it('gets details about one event', function(done){
      request
        .get('/group/501/event/502.json?token=6a66515fcc6b585a69df6b50805146cf8fb91b9c')
        .expect('Content-Type', 'application/json')
        .expect(200, { id: 502,
          event_group_id: 501,
          created_by_user_id: 500,
          utc_timestamp: 0,
          duration: 0,
          created_by_user: { id: 500, name: 'Hans', email: 'hans@example.com', is_admin: 1 },
          event_group: { id: 501, title: 'Event Group 1', text: 'some description' } }
        )
        .end(done);
    });
  });

  describe('POST AUTH /group/:event_group_id/event', function(){
    it('creates new event and create new event_fields for all non-events table fields', function(done){
      request
        .post('/group/501/event.json?token=6a66515fcc6b585a69df6b50805146cf8fb91b9c')
        .send({created_by_user_id: 600, utc_timestamp: '0', duration: '0',
          field1: 'value1', field2: 'value2'})
        .expect('Content-Type', 'application/json')
        .expect(200, { id: 503 })
        .end(done);
    });
  });

  describe('GET AUTH /group/:event_group_id/event/:event_id', function(){
    it('gets details about one event', function(done){
      request
        .get('/group/501/event/503.json?token=6a66515fcc6b585a69df6b50805146cf8fb91b9c')
        .expect('Content-Type', 'application/json')
        .expect(200, { id: 503,
          event_group_id: 501,
          created_by_user_id: 600,
          utc_timestamp: 0,
          duration: 0,
          created_by_user: 
           { id: 600,
             name: 'Peter',
             email: 'peter@example.com',
             is_admin: 1 },
          event_group: { id: 501, title: 'Event Group 1', text: 'some description' } }
        )
        .end(done);
    });
  });

  describe('PUT AUTH /group/:event_group_id/event/:event_id', function(){
    it('updates a event', function(done){
      request
        .put('/group/501/event/503.json?token=6a66515fcc6b585a69df6b50805146cf8fb91b9c')
        .send({created_by_user_id: 500, utc_timestamp: '0', duration: '0'})
        .expect('Content-Type', 'application/json')
        .expect(200, '1')
        .end(done);
    });
  });

  describe('GET AUTH /group/:event_group_id/event/:event_id', function(){
    it('gets details about one event', function(done){
      request
        .get('/group/501/event/503.json?token=6a66515fcc6b585a69df6b50805146cf8fb91b9c')
        .expect('Content-Type', 'application/json')
        .expect(200, { id: 503,
          event_group_id: 501,
          created_by_user_id: 500,
          utc_timestamp: 0,
          duration: 0,
          created_by_user: 
           { id: 500,
             name: 'Hans',
             email: 'hans@example.com',
             is_admin: 1 },
          event_group: { id: 501, title: 'Event Group 1', text: 'some description' } }
        )
        .end(done);
    });
  });

  describe('DELETE AUTH /group/:event_group_id/event/:event_id', function(){
    it('deletes one event', function(done){
      request
        .del('/group/501/event/503.json?token=6a66515fcc6b585a69df6b50805146cf8fb91b9c')
        .expect('Content-Type', 'application/json')
        .expect(200, '1')
        .end(done);
    });
  });


  describe('GET AUTH /group/:id/events', function(){
    it('gets all events for event_groups', function(done){
      request
        .get('/group/501/events.json?token=6a66515fcc6b585a69df6b50805146cf8fb91b9c')
        .expect('Content-Type', 'application/json')
        .expect(200, [ { id: 502,
          event_group_id: 501,
          created_by_user_id: 500,
          utc_timestamp: 0,
          duration: 0,
          created_by_user: { id: 500, name: 'Hans', email: 'hans@example.com', is_admin: 1 },
          event_group: { id: 501, title: 'Event Group 1', text: 'some description' } } ])
        .end(done);
    });
  });


  describe('GET AUTH /group/:event_group_id/events/by_type/:type', function(){
    it('gets events with type', function(done){
      request
        .get('/group/501/events/by_type/whatever.json?token=6a66515fcc6b585a69df6b50805146cf8fb91b9c')
        .expect('Content-Type', 'application/json')
        .expect(200, [ { id: 502,
          event_group_id: 501,
          created_by_user_id: 500,
          utc_timestamp: 0,
          duration: 0,
          created_by_user: { id: 500, name: 'Hans', email: 'hans@example.com', is_admin: 1 },
          event_group: { id: 501, title: 'Event Group 1', text: 'some description' } } ])
        .end(done);
    });
  });

  describe('GET AUTH /group/:event_group_id/events/by_type/:type', function(){
    it('gets events with unknown type', function(done){
      request
        .get('/group/501/events/by_type/dummy.json?token=6a66515fcc6b585a69df6b50805146cf8fb91b9c')
        .expect('Content-Type', 'application/json')
        .expect(200, [])
        .end(done);
    });
  });

  describe('GET AUTH /group/:event_group_id/users', function(){
    it('get all users for event_groups', function(done){
      request
        .get('/group/501/users.json?token=6a66515fcc6b585a69df6b50805146cf8fb91b9c')
        .expect('Content-Type', 'application/json')
        .expect(200, [ { id: 500, name: 'Hans', email: 'hans@example.com' } ])
        .end(done);
    });
  });


});