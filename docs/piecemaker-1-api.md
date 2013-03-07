Piecemaker 1 (before 2013) API
==============================

http://piecemaker.org/

__Pieces__

	Get all available pieces

		/pieces

		curl http://notimetofly.herokuapp.com/api/pieces.js
		curl -H "Accept: text/javascript" http://notimetofly.herokuapp.com/api/pieces


	Get one piece by ID

		/piece/<id:int>

		curl http://notimetofly.herokuapp.com/api/piece/3.js
		curl -H "Accept: text/javascript" http://notimetofly.herokuapp.com/api/piece/3


	Get all videos for a specific piece

		/piece/<id:int>/videos

		curl http://notimetofly.herokuapp.com/api/piece/3/videos.js
		curl -H "Accept: text/javascript" http://notimetofly.herokuapp.com/api/piece/3/videos


	Get all events for a specific piece

		/piece/<id:int>/events

		curl http://notimetofly.herokuapp.com/api/piece/3/events.js
		curl -H "Accept: text/javascript" http://notimetofly.herokuapp.com/api/piece/3/events


	Get specific events by type for a specific piece

		/piece/<id:int>/events/type/<event_type:string>

		curl http://notimetofly.herokuapp.com/api/piece/3/events/type/scene.js
		curl -H "Accept: text/javascript" http://notimetofly.herokuapp.com/api/piece/3/events/type/scene

__Videos__

	Get all videos

		/videos

		curl http://notimetofly.herokuapp.com/api/videos.js
		curl -H "Accept: text/javascript" http://notimetofly.herokuapp.com/api/videos

	Get one video by ID

		/video/<id:int>

		curl http://notimetofly.herokuapp.com/api/video/277.js
		curl -H "Accept: text/javascript" http://notimetofly.herokuapp.com/api/video/277

	Get all events for one video

		/video/<id:int>/events

		curl http://notimetofly.herokuapp.com/api/video/277/events.js
		curl -H "Accept: text/javascript" http://notimetofly.herokuapp.com/api/video/277/events

	Get specific events by type for one video

		/video/<id:int>/events

		curl http://notimetofly.herokuapp.com/api/video/277/events/type/scene.js
		curl -H "Accept: text/javascript" http://notimetofly.herokuapp.com/api/video/277/events/type/scene

__Events__

	Get all events

		/events

		curl http://notimetofly.herokuapp.com/api/video/277/events/type/scene.js
		curl -H "Accept: text/javascript" http://notimetofly.herokuapp.com/api/events

	Get all event between two dates

		/events/between/<date_from:unix timestamp>/<date_to:unix timestamp>

		curl http://notimetofly.herokuapp.com/api/events/between/1293895316/1299165757.js
		curl -H "Accept: text/javascript" http://notimetofly.herokuapp.com/api/events/between/1293895316/1299165757

	Get all event for given parameters

		/events/find

		curl -X POST -H "Accept: text/javascript" --data "event_type=scene" http://notimetofly.herokuapp.com/api/events/find

	Get one event by ID

		/event/<id:int>

		curl http://notimetofly.herokuapp.com/api/event/12131.js
		curl -H "Accept: text/javascript" http://notimetofly.herokuapp.com/api/event/12131

	Get specific events by type

		/events/type/<event_type:string>

		curl http://notimetofly.herokuapp.com/api/events/type/scene.js
		curl -H "Accept: text/javascript" http://notimetofly.herokuapp.com/api/events/type/scene

__Users__

	Get all users

		/login

		curl -X POST -H "Accept: text/javascript" --data "login=Guest&password=Guest" http://notimetofly.herokuapp.com/api/login

	Get one user

		/user_roles

		curl -H "Accept: text/javascript" http://notimetofly.herokuapp.com/api/user_roles


