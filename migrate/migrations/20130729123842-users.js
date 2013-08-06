var dbm = require('db-migrate');
var type = dbm.dataType;

exports.up = function(db, callback) {
	db.createTable(
		'users', 
		{
			id: { 
				type: 'int', primaryKey: true, autoIncrement: true },
			name: { 
				type: 'string', length: 45, notNull: true },
			email: { 
				type: 'string', length: 45, unique: true },
			password: { 
				type: 'string', length: 45, notNull: true },
			api_access_key: {
				type: 'string', length: 45
			},
			is_admin: { 
				type: 'boolean', defaultValue: false },
			is_disabled: { 
				type: 'boolean', defaultValue: false }
		},
		callback
	);
};

exports.down = function(db, callback) {
	db.dropTable( 'users', callback );
};
