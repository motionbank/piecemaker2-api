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
	function (cb) {
		pm1Conn.connect(function(error) {
			if(error) {
				die(error);
			} else {
				cb();
			}
		});
	},
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
		// TODO: reflect user roles from PM1, how?
		pm1Conn.query( 'SELECT * FROM users', [], function ( error, results ) {
			if (error) {
				die(error);
			} else {
				var fns = [];
				if ( emptyBeforeInsert ) {
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
					fns.push(
						(function(n,e,o,l){
							return function (cb) {
								pm2Conn.query('INSERT INTO users (name, email) VALUES (?, ?)',[n,e],function(error,result){
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
						})(userName, userEmail, user.id, user.login)
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
	// EVENTS, finally
	function (cb) {
		// TODO: events_tags, events_users 
		pm1Conn.query('SELECT * FROM events',[],function(error, results){
			if ( error ) {
				die(error)
			} else {
				var fns = [];
				if ( emptyBeforeInsert ) {
					fns.push(
						function (cb) {pm2Conn.query('TRUNCATE events',[],function(e,r){
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
					'title',
					'description',
					'event_type',
					'locked',
					'performers',
					'location',
					'rating',
					// TODO: there are more ...
				];
				for ( var e = 0, k = results.length; e < k; e++ ) {
					var event = results[e];
					var happenedAt = new Date(event.happened_at * 1000); // assumes Florians PM1 version with milliseconds
					var duration = event.dur * 1000;
					var group = newEventGroups[event.piece_id].id;
					if ( !event.created_by ) {
						event.created_by = 'Administrator'
					}
					var createdBy = newUsers[event.created_by].id;
					fns.push(
						(function(t,d,g,u,o){
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
												oldId: o
											};
											cb()
										}
								});
							}
						})(happenedAt.getTime(), duration, group, createdBy, event.id)
					);
					for ( var f = 0, m = eventFields.length; f < m; f++ ) {
						var field = eventFields[f];
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
							})(event.id, field, event[field])
						);
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