var dbm = require('db-migrate');
var type = dbm.dataType;
var async = require('async');

// NOTE THAT THIS WILL NOT WORK ON SQLITE!
// http://stackoverflow.com/questions/1884818/how-do-i-add-a-foreign-key-to-an-existing-sqlite-3-6-21-table

exports.up = function(db, callback) {
	async.series([
		db.runSql.bind( db,
			"ALTER TABLE events ADD CONSTRAINT events_event_group_id_fkey " +
				"FOREIGN KEY (event_group_id) REFERENCES event_groups (id) " +
				"ON UPDATE CASCADE ON DELETE CASCADE"
		),
		db.runSql.bind( db,
			"ALTER TABLE events ADD CONSTRAINT events_created_by_user_id_fkey " +
				"FOREIGN KEY (created_by_user_id) REFERENCES users (id) " +
				"ON UPDATE CASCADE ON DELETE CASCADE"
		),
		db.runSql.bind( db,
			"ALTER TABLE event_fields ADD CONSTRAINT event_fields_event_id_fkey " +
				"FOREIGN KEY (event_id) REFERENCES events (id) " +
				"ON UPDATE CASCADE ON DELETE CASCADE"
		),
		db.runSql.bind( db,
			"ALTER TABLE user_has_event_groups ADD CONSTRAINT user_has_event_groups_event_group_id_fkey " +
				"FOREIGN KEY (event_group_id) REFERENCES event_groups (id) " +
				"ON UPDATE CASCADE ON DELETE CASCADE"
		),
		db.runSql.bind( db,
			"ALTER TABLE user_has_event_groups ADD CONSTRAINT user_has_event_groups_user_id_fkey " +
				"FOREIGN KEY (user_id) REFERENCES users (id) " +
				"ON UPDATE CASCADE ON DELETE CASCADE"
		)
	],callback);
};

exports.down = function(db, callback) {
	async.series([
		db.runSql.bind( db,
			"ALTER TABLE events DROP CONSTRAINT events_event_group_id_fkey"
		),
		db.runSql.bind( db,
			"ALTER TABLE events DROP CONSTRAINT events_created_by_user_id_fkey"
		),
		db.runSql.bind( db,
			"ALTER TABLE event_fields DROP CONSTRAINT event_fields_event_id_fkey"
		),
		db.runSql.bind( db,
			"ALTER TABLE user_has_event_groups DROP CONSTRAINT user_has_event_groups_event_group_id_fkey"
		),
		db.runSql.bind( db,
			"ALTER TABLE user_has_event_groups DROP CONSTRAINT user_has_event_groups_user_id_fkey"
		)
	],callback);
};
