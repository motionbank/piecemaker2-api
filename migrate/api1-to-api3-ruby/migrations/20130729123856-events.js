var dbm = require('db-migrate');
var type = dbm.dataType;

exports.up = function(db, callback) {
	db.createTable(
		'events',
		{
			id: {
				type: 'int', primaryKey: true, autoIncrement: true
			},
			event_group_id: {
				type: 'int', notNull: true
			},
			created_by_user_id: {
				type: 'int'
			},
			utc_timestamp: {
				type: 'double precision', notNull: true
			},
			duration: {
				type: 'double precision', defaultValue: 0
			}
		},
		callback
	);
};

exports.down = function(db, callback) {
	db.dropTable('events', callback);
};
