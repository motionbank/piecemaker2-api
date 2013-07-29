var dbm = require('db-migrate');
var type = dbm.dataType;

exports.up = function(db, callback) {
	db.createTable(
		'event_groups',
		{
			id: {
				type: 'int', primaryKey: true, autoIncrement: true
			},
			title: {
				type: 'string', length: 255
			},
			text: {
				type: 'text'
			}
		},
		callback
	);
};

exports.down = function(db, callback) {
	db.dropTable( 'event_groups', callback );
};
