var request = require('supertest')
var config = require('../../config/test.js');
request = request('http://localhost:' + config.api.port);

describe('controllers/events.js', function(){

  describe('POST AUTH /event/:event_id/field', function(){
    it('create new field for event', function(done){
      request
        .post('/event/502/field.json?token=6a66515fcc6b585a69df6b50805146cf8fb91b9c')
        .send({id: 'custom3', value: 'value3'})
        .expect('Content-Type', 'application/json')
        .expect(200, { id: 0 }) // @FIXME: bug in mysql module?! its not returning insertId
        .end(done);
    });
  });


  describe('GET AUTH /event/:event_id/field/:field_id', function(){
    it('gets one field for event', function(done){
      request
        .get('/event/502/field/custom3.json?token=6a66515fcc6b585a69df6b50805146cf8fb91b9c')
        .expect('Content-Type', 'application/json')
        .expect(200, { value: 'value3' })
        .end(done);
    });
  });


  describe('PUT AUTH /event/:event_id/field/:field_id', function(){
    it('updates a field for an event', function(done){
      request
        .put('/event/502/field/custom3.json?token=6a66515fcc6b585a69df6b50805146cf8fb91b9c')
        .send({value: 'updated value3'})
        .expect('Content-Type', 'application/json')
        .expect(200, '1')
        .end(done);
    });
  });

  describe('GET AUTH /event/:event_id/field/:field_id', function(){
    it('gets one field for event', function(done){
      request
        .get('/event/502/field/custom3.json?token=6a66515fcc6b585a69df6b50805146cf8fb91b9c')
        .expect('Content-Type', 'application/json')
        .expect(200, { value: 'updated value3' })
        .end(done);
    });
  });

  describe('DELETE AUTH /event/:event_id/field/:field_id', function(){
    it('delete one field for an event', function(done){
      request
        .del('/event/502/field/custom3.json?token=6a66515fcc6b585a69df6b50805146cf8fb91b9c')
        .expect('Content-Type', 'application/json')
        .expect(200, '1')
        .end(done);
    });
  });

  describe('GET AUTH /event/:event_id/field/:field_id', function(){
    it('gets one field for event', function(done){
      request
        .get('/event/502/field/custom3.json?token=6a66515fcc6b585a69df6b50805146cf8fb91b9c')
        .expect('Content-Type', 'application/json')
        .expect(200, { })
        .end(done);
    });
  });

});