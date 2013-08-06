var dbm = require('db-migrate');
var type = dbm.dataType;

exports.up = function(db, callback) {
	db.createTable(
		'event_fields',
		{
			event_id: {
				type: 'int', primaryKey: true
			},
			id: {
				type: 'string', length: 32, primaryKey: true
			},
			value: {
				type: 'text' 
			}
		},
		callback
	);
};

exports.down = function(db, callback) {
	db.dropTable( 'event_fields', callback );
};
