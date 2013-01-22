Piecemaker 1 (before 2013) API
==============================

http://piecemaker.org/

__Pieces__

	Get all available pieces

		/pieces

		curl -H "Accept: text/javascript" http://notimetofly.herokuapp.com/api/pieces


	Get one piece by ID

		/piece/<id:int>

		curl -H "Accept: text/javascript" http://notimetofly.herokuapp.com/api/piece/3


	Get all videos for a specific piece

		/piece/<id:int>/videos

		curl -H "Accept: text/javascript" http://notimetofly.herokuapp.com/api/piece/3/videos

__Videos__

	Get all videos

		/videos

		curl -H "Accept: text/javascript" http://notimetofly.herokuapp.com/api/videos

	Get one video by ID

		/video/<id:int>

		curl -H "Accept: text/javascript" http://notimetofly.herokuapp.com/api/video/277

	Get all events for on video

		/video/<id:int>/events

		curl -H "Accept: text/javascript" http://notimetofly.herokuapp.com/api/video/277/events

__Events__

	Get all events

		/events

		curl -H "Accept: text/javascript" http://notimetofly.herokuapp.com/api/events

	Get all event between two dates

		/events/between/<date_from:unix timestamp>/<date_to:unix timestamp>

		curl -H "Accept: text/javascript" http://notimetofly.herokuapp.com/api/events/between/1293895316/1299165757

	Get all event for given parameters

		/events/find

		curl -X POST -H "Accept: text/javascript" --data "event_type=scene" http://notimetofly.herokuapp.com/api/events/find

	Get one event by ID

		/event/<id:int>

		curl -H "Accept: text/javascript" http://notimetofly.herokuapp.com/api/event/12131

__Users__

	Get all users

		/login

		curl -X POST -H "Accept: text/javascript" --data "login=Guest&password=Guest" http://notimetofly.herokuapp.com/api/login

	Get one user

		/user_roles

		curl -H "Accept: text/javascript" http://notimetofly.herokuapp.com/api/user_roles


