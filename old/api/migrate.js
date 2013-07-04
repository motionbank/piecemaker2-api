/**
 *	Migration for PieceMaker-1 to PieceMaker-2 databases
 *
 *	http://motionbank.org/
 *	fjenett 2013-01
 */

var mysql = require('mysql');

/**
 *	Run a series of functions in sequence
 */

var Sequential = (function(){
	var _Sequential = function () {
		this.callbacks = arguments[0];
		this.currentCallback = 0;
		this.finalCallback = arguments[1];
		this.nextCallback();
	}
	_Sequential.prototype.nextCallback = function () {
		if ( this.currentCallback == this.callbacks.length ) {
			this.finalCallback.call();
		} else {
			this.callbacks[this.currentCallback].call(this,
				(function(s){
					return function () { s.nextCallback() };
				})(this)
			);
		}
		this.currentCallback++;
	}
	return _Sequential;
})();

/**
 *	Utility func to message and exit
 */

function die ( message ) {
	console.log( message );
	process.exit();
}

/**
 *	Configurations / settings
 */

var pieceMaker1 = {
	mysql : {
		host: 'localhost',
	    database: 'deborah_hay',
	    user: 'pm',
	    password: 'pm',
	    debug: false
	}
}
var pieceMaker2 = {
	mysql : {
		host: 'localhost',
	    database: 'deborah_hay_pm2',
	    user: 'pm',
	    password: 'pm',
	    debug: false
	}
}

// empty table before inserting
var emptyBeforeInsert = true;

/**
 *	Global variables
 */

var pm1Conn = mysql.createConnection( pieceMaker1.mysql ),
	pm2Conn = mysql.createConnection( pieceMaker2.mysql );

var newUsers = [],
	newEventGroups = [],
	newEvents = [];

/**
 *	Zap, here we go ..
 */

new Sequential([
	// connect source database
	function (cb) {
		pm1Conn.connect(function(error) {
			if(error) {
				die(error);
			} else {
				cb();
			}
		});
	},
	// connect destination database
	function (cb) {
		pm2Conn.connect(function(error) {
			if(error) {
				die(error);
			} else {
				cb();
			}
		});
	},
	// USERS go first
	function (cb) {
		pm1Conn.query( 'SELECT * FROM users', [], function ( error, results ) {
			if (error) {
				die(error);
			} else {
				var fns = [];
				if ( emptyBeforeInsert ) {
					// need to erase events first as they are referenced by users table
					fns.push(
						function (cb) {
							pm2Conn.query('TRUNCATE events',[],function(e,r){
								if (e) {
									die(e);
								} else {
									cb();
								}
							});
						}
					);
					fns.push(
						function (cb) {
							pm2Conn.query('TRUNCATE user_has_event_groups',[],function(e,r){
								if (e) {
									die(e);
								} else {
									cb();
								}
							});
						}
					);
					fns.push(
						function (cb) {
							pm2Conn.query('TRUNCATE users',[],function(e,r){
								if (e) {
									die(e);
								} else {
									cb();
								}
							});
						}
					);
				}
				for ( var u = 0, k = results.length; u < k; u++ ) {
					var user = results[u];
					var userName = user.name ? user.name : user.login;
					var userEmail = user.email ? user.email : user.login.toLowerCase().replace(/[^-_.a-z0-9]/,'')+'-fake@motionbank.org';
					var userPassword = new Buffer(user.email+(new Date()).getTime()).toString('base64');
					fns.push(
						(function(n,e,o,l,p,a){
							return function (cb) {
								pm2Conn.query( 'INSERT INTO users (name, email, password, api_access_key, is_admin) '+
													'VALUES (?, ?, ?, SHA1(?), ?)', 
											   [n,e,p,p,a], function(error,result){
									if (error) {
										die(error)
									} else {
										newUsers[l] = {
											id: result.insertId,
											name: n,
											oldId: o,
											login: l
										};
										cb();
									}
								});
							}
						})(userName, userEmail, user.id, user.login, userPassword, user.role_name === 'group_admin')
					);
				}
				new Sequential(fns,function(){
					cb();
				});
			}
		});
	},
	// EVENT GROUPS next
	function (cb) {
		pm1Conn.query('SELECT p.id, p.title, mi.description FROM pieces AS p LEFT JOIN meta_infos AS mi ON p.id = mi.piece_id',[],function(error,results){
			if(error) {
				die(error);
			} else {
				var fns = [];
				if ( emptyBeforeInsert ) {
					fns.push(
						function(cb) {
							pm2Conn.query('TRUNCATE event_groups',[],function(e,r){
								if(e){
									die(e)
								} else {
									cb()
								}
							});
						}
					);
				}
				for ( var p = 0, k = results.length; p < k; p++ ) {
					var piece = results[p];
					fns.push(
						(function(t,d,o){
							return function (cb) {
								pm2Conn.query('INSERT INTO event_groups (title, text) VALUES (?,?)',[t,d],function(error,result){
									if(error){
										die(error)
									} else {
										newEventGroups[o] = {
											id: result.insertId,
											oldId: o
										};
										cb()
									}
								});
							}
						})(piece.title,piece.description, piece.id)
					);
				}
				new Sequential(fns,function(){
					cb()
				})
			}
		});
	},
	// USER rights
	function (cb) {
		pm1Conn.query('SELECT DISTINCT piece_id, created_by FROM events WHERE created_by IS NOT NULL',[],function(error, results){
			if (error) {
				die(error);
			} else {
				var fns = [];
				if (emptyBeforeInsert) {
					// connection should have been deleted at USER step above
				}
				for ( var r = 0, k = results.length; r < k; r++ ) {
					var userGroup = results[r];
					if ( !newUsers[userGroup.created_by] ) continue; // no need to bind non-existant user
					var userId = newUsers[userGroup.created_by].id;
					if ( !newEventGroups[userGroup.piece_id] ) {
						console.log( "Piece/group does not exit: "+userGroup.piece_id );
						console.log( "Ignored" );
						continue;
					}
					var groupId = newEventGroups[userGroup.piece_id].id;
					fns.push(
						(function(u,g){
							return function (cb) {
								// TODO: use PM1 roles_matrix to decide on CRUD rights
								pm2Conn.query(
									'INSERT INTO user_has_event_groups '+
									'(user_id, event_group_id, allow_read, allow_create, allow_update, allow_delete) '+
									'VALUES (?, ?, 1, 1, 1, 1)',
									[u,g],
									function (e,r) {
										if (e) {
											die(e)
										} else {
											// assume OK then
											cb()
										}
									}
								);
							}
						})(userId, groupId)
					);
				}
				new Sequential(fns,function(){
					cb()
				});
			}
		});
	},
	// EVENTS, finally
	function (cb) {
		// TODO: events_tags, events_users 
		pm1Conn.query('SELECT * FROM events ORDER BY id',[],function(error, results){
			if ( error ) {
				die(error)
			} else {
				var fns = [];
				if ( emptyBeforeInsert ) {
					fns.push(
						function (cb) { pm2Conn.query('TRUNCATE events',[],function(e,r){
							if (e) {
								die(e)
							} else {
								cb()
							}
						})}
					);
					fns.push(
						function (cb) {pm2Conn.query('TRUNCATE event_fields',[],function(e,r){
							if (e) {
								die(e)
							} else {
								cb()
							}
						})}
					);
				}
				var eventFields = [
					'type',
					'title',
					'description',
					'event_type',
					'locked',
					'performers',
					'location',
					'rating',
					// TODO: there are more ...
				];
				var eventFieldsReplacement = {
					description: 'body',
					event_type: 'type'
				};
				for ( var e = 0, k = results.length; e < k; e++ ) {
					var event = results[e];
					var happenedAt = new Date(event.happened_at * 1000); // assumes Florians PM1 version with milliseconds
					var duration = event.dur;
					var group = newEventGroups[event.piece_id].id;
					if ( !event.created_by ) {
						event.created_by = 'Administrator'
					}
					var createdBy = newUsers[event.created_by].id;
					fns.push(
						(function(t,d,g,u,o,e){
							return function(cb){
								pm2Conn.query(
									'INSERT INTO events (`utc_timestamp`, duration, `event_group_id`, `created_by_user_id`) VALUES (?,?,?,?)',
									[t,d,g,u],
									function(e,r){
										if (e) {
											die(e)
										} else {
											newEvents[o] = {
												id: r.insertId,
												srcModel: 'event',
												oldId: o
											};
											cb()
										}
								});
							}
						})(happenedAt.getTime(), duration, group, createdBy, event.id, event)
					);
					// add fields
					for ( var f = 0, m = eventFields.length; f < m; f++ ) {
						var field = eventFields[f];
						var fieldName = eventFieldsReplacement[field] || field;

						if ( event.event_type == 'data' && field == 'description' ) continue; // skip data part of data events
						
						if (event[field]) {
							fns.push(
								(function(o,i,v){
									return function (cb) {
										pm2Conn.query(
											'INSERT INTO event_fields (`event_id`, id, value) VALUES (?,?,?)',
											[newEvents[o].id,i,v],
											function(e,r){
												if(e) {
													die(e)
												} else {
													cb()
												}
										})
									}
								})(event.id, fieldName, event[field])
							);
						}
					}
					if ( event.event_type == 'data' ) {
						var data = (new Function('return ('+event.description+')'))();
						for ( var p in data ) {
							var value = data[p];
							fns.push(
								(function(o,i,v){
									return function (cb) {
										pm2Conn.query(
											'INSERT INTO event_fields (`event_id`, id, value) VALUES (?,?,?)',
											[newEvents[o].id,i,v],
											function(e,r){
												if(e) {
													die(e)
												} else {
													cb()
												}
										})
									}
								})(event.id, 'data-'+p, value)
							);
						}
					}
				}
				new Sequential(fns,function(){
					cb()
				});
			}
		});
	},
	// VIDEOS are events too
	function (cb) {
		pm1Conn.query('SELECT * FROM videos AS v JOIN video_recordings AS r ON v.id = r.video_id',[],
						function(error, results){
			if (error) {
				die(error);
			} else {
				var fns = [];
				if (emptyBeforeInsert) {
					// not needed as it should already have been done at EVENTS above
				}
				var videoFields = [
					'event_type',
					'title',
					'meta_data',
					'rating',
					'group_id',
					'fn_local',
					'fn_s3',
					'fn_arch',
					'vid_type',
					// TODO: there are more ...
				];
				var eventFieldsReplacement = {
					description: 'body',
					event_type: 'type'
				};
				for ( var v = 0, k = results.length; v < k; v++ ) {
					var video = results[v];
					video.event_type = 'video';
					var happenedAt = new Date(video.recorded_at * 1000); // assumes Florians PM1 version with milliseconds
					var duration = video.duration;
					var group = newEventGroups[video.piece_id].id;
					if ( !video.created_by ) {
						video.created_by = 'Administrator'
					}
					var createdBy = newUsers[video.created_by].id;
					fns.push((function(t,d,g,u,o){
						return function (cb) {
							pm2Conn.query(
								'INSERT INTO events (`utc_timestamp`, duration, `event_group_id`, `created_by_user_id`) VALUES (?,?,?,?)',
								[t,d,g,u],
								function (e,r) {
									if (e) {
										die(e)
									} else {
										newEvents['video-'+o] = {
											id: r.insertId,
											srcModel: 'video',
											oldId: o
										};
										cb()
									}
								});
						}
					})(happenedAt.getTime(), duration, group, createdBy, video.id));
					// add fields
					for ( var f = 0, m = videoFields.length; f < m; f++ ) {
						var field = videoFields[f];
						var fieldName = eventFieldsReplacement[field] || field;
						if ( video[field] ) {
							fns.push(
								(function(o,i,v){
									return function (cb) {
										pm2Conn.query(
											'INSERT INTO event_fields (`event_id`, id, value) VALUES (?,?,?)',
											[newEvents['video-'+o].id,i,v],
											function(e,r){
												if(e) {
													die(e)
												} else {
													cb()
												}
										})
									}
								})(video.id, fieldName, video[field])
							);
						}
					}
				}
				new Sequential(fns,function(){
					cb()
				});
			}
		});
	}
	],function(){
		// console.log( newUsers );
		// console.log( newEventGroups );
		// console.log( newEvents );
		console.log( "Done!" );
		process.exit();
	});