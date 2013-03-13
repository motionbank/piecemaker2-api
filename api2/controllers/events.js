module.exports = {

  'POST AUTH /event/:event_id/field':
  // create new field for event
  //  likes token*, id*, value*
  //  returns {id}
  function($, event_id) {
    $.db.query('INSERT INTO event_fields SET ' +
      'event_id=?, id=?, value=?',
      [event_id, $.params.id, $.params.value],
      function(err, result){
        if(err) return $.internalError(err);
        return $.render({id: result.insertId});
      }
    );
  },

  'GET AUTH /event/:event_id/field/:field_id':
  // get one field for event 
  //  likes token*
  //  returns {value}
  function($, event_id, field_id) {
    $.db.query('SELECT value ' +
      'FROM event_fields WHERE event_id=? AND id=? LIMIT 1',
      [event_id, field_id],
      function(err, result){
        if(err) return $.internalError(err);
        return $.render(result[0]);
      }
    );
  },  

  'PUT AUTH /event/:event_id/field/:field_id':
  // updates a field for an event
  //  likes token*, value
  //  returns boolean
  function($, event_id, field_id) {
    $.db.query('UPDATE event_fields SET ' +
      'value=? ' +
      'WHERE event_id=? AND id=? LIMIT 1',
      [$.params.value, $.params.event_id, $.params.field_id],
      function(err, result){
        if(err) return $.internalError(err);
        return $.render(result.affectedRows);
      }
    );
  },

  'DELETE AUTH /event/:event_id/field/:field_id':
  // delete one field for an event
  //  likes token*
  //  returns boolean
  function($, event_id, field_id) {
    $.db.query('DELETE FROM event_fields WHERE event_id=? AND id=? LIMIT 1',
      [event_id, field_id],
      function(err, result){
        if(err) return $.internalError(err);
        return $.render(result.affectedRows);
      }
    );
  }

}