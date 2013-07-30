var mysql 	= require('mysql'),
	pg 		= require('pg'),
	sqlite3 = require('sqlite3'),
	path 	= require('path'),
	assert  = require('assert'),
	async   = require('async'),
	yaml    = require('js-yaml'),
	argv	= require('optimist').argv;

// This is a hack using db-migrate as a db agnostic connection

var db_migrate_path = path.dirname( path.normalize( require.resolve('db-migrate') ) );
var driver = require( db_migrate_path + '/lib/driver' );

// Parse command line options

var project = argv.p || argv.project || null;

// Load appropriate config file

var config  = require(__dirname+'/config/config'+(project ? '-'+project : ''));

// Some global settings

var srcEventFieldsToIgnore = [
	'id', 'recorded_at', 'dur', 'happened_at', 'duration',
	'updated_at', 'created_at', 'created_by', 'modified_by',
	'piece_id', 'parent_id', 'video_id', 'inherits_title',
	'highlighted', 'primary'
];

// Let's begin with the migration

(function migrate () {
	var srcDb 	= null,
		destDb 	= null;

	async.series([
		function (next) {
			driver.connect( config.srcDB.db, function(err, db){
				assert.ifError(err);
				srcDb = db;
				console.log( "source db ("+config.srcDB.db.driver+") connected" );
				next();
			});
		},
		function (next) {
			driver.connect( config.destDB.db, function(err, db){
				assert.ifError(err);
				destDb = db;
				console.log( "destination db ("+config.destDB.db.driver+") connected" );
				next();
			});
		},
		function (next) {
			destDb.runSql(
				'TRUNCATE events, users, event_fields, event_groups, user_has_event_groups',
				[],
				next
			);
		},
		function (next) {
			console.log( 'migrating users ...' );
			migrateUsers( srcDb, destDb, next );
		},
		function (next) {
			console.log( 'get / add migration user ...' );
			getCreateMigrationUser( destDb, next );
		},
		function (next) {
			console.log( 'migrating groups ...' );
			migrateGroups( srcDb, destDb, next );
		},
		function (next) {
			console.log( 'establishing user to group relations ...' );
			migrateUserHasGroups( srcDb, destDb, next );
		},
		function (next) {
			console.log( 'migrating events ...' );
			migrateEvents( srcDb, destDb, next );
		}
	],function(){
		console.log( 'fin!' );
		process.exit();
	});
})();

// Migrate users
// -------------

function migrateUsers ( srcDb, destDb, next ) {

	async.waterfall([
		function loadSourceUsers (next) {
			srcDb.all('SELECT * FROM USERS',function(err,users){
				assert.ifError(err);
				next(null, users);
			});
		},
		function prepareAndSaveDestUsers (srcUsers, next) {
			async.map( 
				srcUsers, 
				translateUserData, 
				function(err, destUsers){
					assert.ifError(err);
					async.each( 
						destUsers, 
						function saveUserData (userData, next) {
							destDb.insert(
								'users',
								['name', 'email', 'password', 'api_access_key', 'is_admin', 'is_disabled'],
								[userData.name, userData.email, userData.password, userData.api_access_key, 
									userData.is_admin, userData.is_disabled],
								next
							);
						}, 
						function (err) {
							assert.ifError( err );
							next();
						}
					);
				}
			);
		}
	],function(){
		console.log( 'done migrating users' );
		next();
	});
}

function translateUserData ( srcUser, next ) {
	next(
		null, 
		{
			name: 			srcUser.login,
			email: 			(srcUser.email || srcUser.login + '@fake-email.motionbank.org').toLowerCase(),
			password: 		sha1( srcUser.login + (Math.random() * 10 + (new Date().getTime())) ).substring(0,6),
			api_access_key: sha1( ((new Date().getTime()) + Math.random() * 666) + srcUser.login ),
			is_admin: 		srcUser.role_name === 'group_admin' ? true : false,
			is_disabled: 	false
		}
	);
}

// Add migration user to destination database
// ------------------------------------------

function getCreateMigrationUser ( destDb, next ) {
	destDb.all(
		'SELECT id, name FROM users',
		function ( err, users ) {
			var migrationUser = null;
			var setUserAndGo = function (user) {
				getMigrationUser = function () {
					return user;
				};
				//console.log( getMigrationUser() );
				next();
			}
			async.each(
				users,
				function (user, next){
					if ( user.name === 'Migration User' ) {
						migrationUser = user;
					}
					next();
				},
				function (err) {
					if ( !migrationUser ) {
						destDb.insert( 
							'users',
							['name', 'email', 'password'],
							['Migration User', 'migration@fake-email@motionbank.org', sha1(new Date().getTime())],
							function (err) {
								assert.ifError(err);
								destDb.all(
									'SELECT id, name FROM users WHERE name LIKE \'Migration User\'',
									function ( err, migrationUser ) {
										assert.ifError(err);
										setUserAndGo( migrationUser[0] );
									}
								);
							}
						);
					}
					else {
						setUserAndGo( migrationUser );
					}
				}
			);
		}
	);
}

// Migrate groups
// --------------

function migrateGroups ( srcDb, destDb, next ) {

	async.waterfall([
		function loadSourceGroups (next) {
			srcDb.all(
				'SELECT * FROM pieces',
				function ( err, pieces ) {
					assert.ifError( err );
					next(null, pieces);
				}
			);
		},
		function perpareAndSaveGroups (srcGroups, next) {
			async.map( 
				srcGroups, 
				translateGroupData,
				function (err,destGroups) {
					async.each(
						destGroups,
						function saveDestGroup ( destGroup, next ) {
							destDb.insert(
								'event_groups',
								['title','text'],
								[destGroup.title,destGroup.text],
								next
							);
						}, 
						function (err) {
							assert.ifError( err );
							next();
						}
					);
				}
			);
		}
	],function () {
		console.log( 'done migrating groups' );
		next();
	});
}

function translateGroupData ( srcGroup, next ) {
	next(
		null,
		{
			title: srcGroup.short_name,
			text:  srcGroup.title + "\n" + srcGroup.created_at
		}
	);
}

// Link users and groups
// =====================

function migrateUserHasGroups ( srcDb, destDb, next ) {
	
	async.waterfall([
		function (nextC) {
			loadSourceGroups(srcDb, function(pieces){
				nextC(null, pieces);
			});
		},
		function (srcGroups, nextD) {
			loadSrcDestGroupsMap(srcGroups, destDb, function(map){
				nextD(null, map);
			});
		},
		function (srcDestGroupMap, next) {
			destDb.all(
				'SELECT * FROM users',
				function (err, users) {
					assert.ifError(err);
					var destUsersByLogin = [];
					for ( var i = 0; i < users.length; i++ ) {
						destUsersByLogin[users[i].name] = users[i];
					}
					next( null, srcDestGroupMap, destUsersByLogin );
				}
			);
		},
		function (srcDestGroupMap, destUsers, nextB) {
			async.each(
				srcDestGroupMap,
				function ( tuple, next ) {
					srcDb.all(
						'SELECT users.login, events.piece_id FROM events '+
						'JOIN users ON events.created_by = users.login OR '+
									  'events.modified_by = users.login '+
						'WHERE events.piece_id = ' + tuple.src.id + ' '+
						'GROUP BY users.login, piece_id ',
						function ( err, groupUsers ) {
							assert.ifError( err );
							async.each(
								groupUsers,
								function ( groupUser, next ) {
									destDb.insert(
										'user_has_event_groups',
										['user_id','event_group_id'],
										[destUsers[groupUser.login].id, tuple.dest.id],
										function (err) {
											assert.ifError(err);
											next();
										}
									);
								},
								function () {
									next();
								}
							);
						}
					);
				},
				function () {
					nextB();
				}
			);
		}
	],function(){
		console.log('done relating users to groups');
		next();
	});
}

// Migrate events
// ==============

function migrateEvents ( srcDb, destDb, nextA ) {

	// TODO: missing are
	// "event_tags -> tags"
	// "event_users -> users"
	// "event.id -> notes"
	
	async.waterfall([
		function (nextC) {
			loadSourceGroups(srcDb, function(pieces){
				nextC(null,pieces);
			});
		},
		function (srcGroups, nextD) {
			loadSrcDestGroupsMap(srcGroups, destDb, function(map){
				nextD(null,map);
			});
		},
		function (srcDestGroupMap, nextB) {
			var groupsDone = 0;
			for ( var i = 0; i < srcDestGroupMap.length; i++ ) {
				srcDestTuple = srcDestGroupMap[i];
				async.series([
						function (next) {
							migrateSrcVideos( srcDb, destDb, srcDestTuple, next );
						},
						function (next) {
							migrateSrcEvents( srcDb, destDb, srcDestTuple, next );
						}
					],function(err){
						assert.ifError(err);
						groupsDone++;
						if ( groupsDone === srcDestGroupMap.length ) {
							nextB();
						}
					}
				);
			}
		}
	],function(){
		console.log('done migrating events');
		nextA();
	});
}

function loadSourceGroups (srcDb, cb) {
	srcDb.all(
		'SELECT * FROM pieces',
		function (err, pieces) {
			assert.ifError(err);
			cb(pieces);
		}
	);
};

function loadSrcDestGroupsMap (srcGroups, destDb, cb) {
	destDb.all(
		'SELECT * FROM event_groups',
		function(err,groups){
			assert.ifError(err);
			async.map(
				groups,
				function (destGroup,next) {
					for ( var k = 0; k < srcGroups.length; k++ ) {
						if ( srcGroups[k].short_name === destGroup.title ) {
							next(null,{src:srcGroups[k],dest:destGroup});
							return;
						}
					}
					next('Error mapping source to destination groups in migrate events!',null);
				},
				function(err,map){
					assert.ifError(err);
					cb(map);
				}
			);
		}
	);
};

function migrateSrcVideos ( srcDb, destDb, srcDestTuple, nextG ) {

	async.waterfall([
		function loadSourceVideos (next) {
			srcDb.all(
				'SELECT * FROM videos '+
					'LEFT OUTER JOIN video_recordings ON videos.id = video_id '+
					'WHERE piece_id = ?',
				[srcDestTuple.src.id],
				function (err, videos) {
					assert.ifError(err);
					next(null, videos);
				}
			);
		},
		function prepareAndSaveSourceVideos (srcVideos, nextD) {
			if ( srcVideos && srcVideos.length > 0 ) {
				async.map(
					srcVideos,
					(function(t){return function(v,n){ translateSourceEventToDestEvent(v,t,n); };})(srcDestTuple),
					function (err, destVideoEvents) {
						assert.ifError(err);
						//console.log(destVideoEvents);
						async.each(
							destVideoEvents,
							function(destVideo,next){
								var columns = ['event_group_id', 'created_by_user_id', 
										'utc_timestamp', 'duration'];

								var values = [destVideo.event_group_id, destVideo.created_by_user_id,
										destVideo.utc_timestamp, destVideo.duration];

								destDb.runSql(
									'INSERT INTO events ('+columns.join(',')+') '+
											'VALUES ('+values.join(',')+') '+
											'RETURNING id', // TODO: only works with Postgres
									function (err, dbResult) {
										assert.ifError(err);
										if ( dbResult && dbResult.rows && dbResult.rows.length > 0 ) {
											var event_id = dbResult.rows[0].id;
											async.each(
												destVideo.fields,
												function(field,next){
													field.value = field.value.replace(/'/g,'´');
													destDb.insert(
														'event_fields',
														['event_id', 'id', 'value'],
														[event_id, field.id, field.value],
														function(err){
															assert.ifError(err);
															next();
														}
													);
												},
												function(){
													next();
												}
											);
										} else {
											next();
										}
									}
								);

							},
							function(err){
								assert.ifError(err);
								nextD();
							}
						);
					}
				);
			} else {
				console.log( 'piece has no videos ..? skipped' );
				nextD();
			}
		}
	],function(){
		nextG();
	});
}

function migrateSrcEvents ( srcDb, destDb, srcDestTuple, nextZ ) {

	async.waterfall([
		function loadSourceEvents (next) {
			srcDb.all(
				'SELECT * FROM events',
				function ( err, events ) {
					assert.ifError(err);
					next(null, events);
				}
			);
		},
		function prepareAndSaveSourceEvents (srcEvents, nextB) {
			if ( srcEvents && srcEvents.length > 0 ) {
				async.map(
					srcEvents,
					(function(t){
						return function(e,n){ translateSourceEventToDestEvent(e,t,n); };
					})( srcDestTuple ),
					function (err, destEvents) {
						//console.log(destEvents);
						async.each(
							destEvents,
							function(destEvent, next){

								var columns = ['event_group_id', 'created_by_user_id', 
										'utc_timestamp', 'duration'];

								var values = [destEvent.event_group_id, destEvent.created_by_user_id,
										destEvent.utc_timestamp, destEvent.duration];

								destDb.runSql(
									'INSERT INTO events ('+columns.join(',')+') '+
											'VALUES ('+values.join(',')+') '+
											'RETURNING id', // TODO: only works with Postgres
									function (err, dbResult) {
										assert.ifError(err);
										if ( dbResult && dbResult.rows && dbResult.rows.length > 0 ) {
											var event_id = dbResult.rows[0].id;
											async.each(
												destEvent.fields,
												function(field,next){
													field.value = field.value.replace(/'/g,'´');
													destDb.insert(
														'event_fields',
														['event_id', 'id', 'value'],
														[event_id, field.id, field.value],
														function(err){
															assert.ifError(err);
															next();
														}
													);
												},
												function(){
													next();
												}
											);
										} else {
											next();
										}
									}
								);
							},
							function(err){
								assert.ifError(err);
								nextB();
							}
						);
					}
				);
			} else {
				nextB();
			}
		}
	],function(err){
		assert.ifError(err);
		nextZ();
	});
}

// This is being used for both video and normal events ...

function translateSourceEventToDestEvent ( srcEvent, srcDestTuple, next ) {
	var fields = [];
	if ( srcEvent.recorded_at ) {
		fields.push({id: 'event_type', value: 'video'});
	}
	for ( var k in srcEvent ) {
		if ( k && srcEvent.hasOwnProperty(k) && srcEvent[k] ) {
			if ( srcEventFieldsToIgnore.indexOf(k) === -1 )
			{
				var val = srcEvent[k];
				if ( k === 'performers' ) {
					val = yaml.load(val);
					if ( val && val instanceof Array ) {
						if ( val.length > 0 ) {
							val = val.join(',');
						} else {
							continue;
						}
					} else {
						continue;
					}
				}
				fields.push({
					id: k,
					value: val
				});
			}
		}
	}
	var timestamp = srcEvent.happened_at || srcEvent.recorded_at;
	try {
		timestamp = parseFloat( timestamp );
	} catch ( e ) {
		timestamp = new Date( srcEvent.happened_at ).getTime() / 1000.0;
	}
	var duration = srcEvent.duration || srcEvent.dur || 0;
	next(
		null,
		{
			event_group_id: 	srcDestTuple.dest.id,
			created_by_user_id: getMigrationUser().id,
			utc_timestamp:  	timestamp,
			duration: 			duration,
			fields: 			fields
		}
	);
}

// Helpers
// -------

// Wraps the sha1 crypto digest

function sha1 ( str ) {
	var crypto = require( 'crypto' ),
		shasum = crypto.createHash('sha1');
	shasum.update( str+'' );
	return shasum.digest('hex');
}

// stub to be filled after users were created

var getMigrationUser = null;
