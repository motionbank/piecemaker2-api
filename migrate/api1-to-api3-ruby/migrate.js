var mysql 	= require('mysql'),
	pg 		= require('pg'),
	sqlite3 = require('sqlite3'),
	config  = require(__dirname+'/config'),
	path 	= require('path'),
	assert  = require('assert'),
	async   = require('async'),
	yaml    = require('js-yaml');

var db_migrate_path = path.dirname( path.normalize( require.resolve('db-migrate') ) );
var driver = require( db_migrate_path + '/lib/driver' );

(function migrate () {
	var srcDb 	= null,
		destDb 	= null;

	async.series([
		function (next) {
			driver.connect( config.srcDB.db, function(err, db){
				assert.ifError(err);
				srcDb = db;
				console.log( "src db connected" );
				next();
			});
		},
		function (next) {
			driver.connect( config.destDB.db, function(err, db){
				assert.ifError(err);
				destDb = db;
				console.log( "dest db connected" );
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
			migrateUsers( srcDb, destDb, next );
		},
		function (next) {
			getCreateMigrationUser( destDb, next );
		},
		function (next) {
			migrateGroups( srcDb, destDb, next );
		},
		function (next) {
			migrateEvents( srcDb, destDb, next );
		}
	],function(){
		console.log( 'done' );
		process.exit();
	});
})();

// Migrate users
// -------------

function migrateUsers ( srcDb, destDb, next ) {
	var srcUsers = null;
	async.series([
		function loadSourceUsers (next) {
			srcDb.all('SELECT * FROM USERS',function(err,results){
				assert.ifError(err);
				srcUsers = results;
				next();
			});
		},
		function prepareAndSaveDestUsers (next) {
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
			email: 			srcUser.email || srcUser.login + '@fake-email.motionbank.org',
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
	var srcGroups = null;
	async.series([
		function loadSourceGroups (next) {
			srcDb.all(
				'SELECT * FROM pieces',
				function ( err, pieces ) {
					assert.ifError( err );
					srcGroups = pieces;
					next();
				}
			);
		},
		function perpareAndSaveGroups (next) {
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

// Migrate events
// ==============

function migrateEvents ( srcDb, destDb, nextA ) {
	
	var srcGroups, srcDestGroupMap, destUsers;
	var sourceEventsByGroup = null;

	async.series([
		function (nextC) {
			loadSourceGroups(srcDb, function(pieces){
				srcGroups = pieces;
				nextC();
			});
		},
		function (nextD) {
			loadSrcDestGroupsMap(srcGroups, destDb, function(map){
				srcDestGroupMap = map;
				nextD();
			});
		},
		function ( nextB ) {
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
	var srcVideos = [];
	async.series([
		function loadSourceVideos (next) {
			srcDb.all(
				'SELECT * FROM videos '+
					'LEFT OUTER JOIN video_recordings ON videos.id = video_id '+
					'WHERE piece_id = ?',
				[srcDestTuple.src.id],
				function (err, videos) {
					assert.ifError(err);
					srcVideos = videos;
					next();
				}
			);
		},
		function prepareAndSaveSourceVideos (nextD) {
			if ( srcVideos && srcVideos.length > 0 ) {
				async.map(
					srcVideos,
					(function(t){return function(v,n){ translateSourceVideoToEvent(v,t,n); };})(srcDestTuple),
					function (err, destVideoEvents) {
						assert.ifError(err);
						//console.log(destVideoEvents);
						async.each(
							destVideoEvents,
							function(destVideo,next){
								// destDb.insert(
								// 	'events',
								// 	['event_group_id', 'created_by_user_id', 
								// 		'utc_timestamp', 'duration'],
								// 	[destVideo.event_group_id, destVideo.created_by_user_id,
								// 		destVideo.utc_timestamp, destVideo.duration],
								// 	next
								// );

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

function translateSourceVideoToEvent (srcVideo, srcDestTuple, next) {
	//console.log( srcVideo );
	var fields = [
			{id: 'event_type', value: 'video'}
		],
		skipFields = ['id','recorded_at','duration','piece_id',
						'updated_at','created_at','primary', 'video_id']; 
	for ( var k in srcVideo ) {
		if ( k && srcVideo.hasOwnProperty(k) && srcVideo[k] ) {
			if ( skipFields.indexOf(k) === -1 )
			{
				fields.push({
					id: k,
					value: srcVideo[k]
				});
			}
		}
	}
	next(
		null,
		{
			event_group_id: srcDestTuple.dest.id,
			created_by_user_id: getMigrationUser().id,
			utc_timestamp:  new Date( srcVideo.recorded_at ).getTime(), // TODO: ts/1000.0 ??
			duration: 		srcVideo.duration,
			fields: 		fields
 		}
	);
}

function migrateSrcEvents ( srcDb, destDb, srcDestTuple, nextZ ) {

	var srcEvents = [];

	async.series([
		function loadSourceEvents (next) {
			srcDb.all(
				'SELECT * FROM events',
				function ( err, events ) {
					assert.ifError(err);
					srcEvents = events;
					next();
				}
			);
		},
		function prepareAndSaveSourceEvents (nextB) {
			if ( srcEvents && srcEvents.length > 0 ) {
				async.map(
					srcEvents,
					(function(t){
						return function(e,n){ translateSourceEventToEvent(e,t,n); };
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

function translateSourceEventToEvent ( srcEvent, srcDestTuple, next ) {
	var fields = [], 
		skipFields = ['id','recorded_at','dur', 'happened_at', 'duration','piece_id',
					  'updated_at','created_at', 'created_by', 'modified_by',
					  'parent_id','video_id','inherits_title','highlighted']; 
	for ( var k in srcEvent ) {
		if ( k && srcEvent.hasOwnProperty(k) && srcEvent[k] ) {
			if ( skipFields.indexOf(k) === -1 )
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
	next(
		null,
		{
			event_group_id: srcDestTuple.dest.id,
			created_by_user_id: getMigrationUser().id,
			utc_timestamp:  new Date( srcEvent.happened_at ).getTime(), // TODO: ts/1000.0 ??
			duration: 		srcEvent.dur || 0,
			fields: 		fields
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
