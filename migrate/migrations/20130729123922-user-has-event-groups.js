var dbm = require('db-migrate');
var type = dbm.dataType;

exports.up = function(db, callback) {
	db.createTable(
		'user_has_event_groups',
		{
			user_id: {
				type: 'int',
				primaryKey: true
			},
			event_group_id: {
				type: 'int',
				primaryKey: true
			}
		},
		callback
	);
};

exports.down = function(db, callback) {
	db.dropTable( 'user_has_event_groups', callback );
};
