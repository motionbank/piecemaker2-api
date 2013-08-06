var dbm = require('db-migrate');
var type = dbm.dataType;

exports.up = function(db, callback) {
	db.addColumn( 
		'event_groups', 
		'created_at',
		{
			type: 'datetime',
			notNull: true
		},
		callback);
};

exports.down = function(db, callback) {
	db.dropColumn(
		'event_groups',
		'created_at',
		callback
	);
};
