API Definition for PieceMaker 2, draft
======================================

Trying to sketch the API routes.

__USERS__
```
GET  /users
POST /user
GET  /user/:id
GET  /user/:name
PUT  /user/:id
DEL  /user/:id

GET  /user/:id/events
	--> fields already included?
GET  /user/:id/event_groups
```

__EVENTS__
```
GET  /events
POST /event
GET  /event/:id
	--> fields already included?
PUT  /event/:id
DEL  /event/:id
```

__EVENT FIELDS__
```
GET  /event/:id/fields

POST /event/:id/field
GET  /event/:id/field/:key
	--> what if event has multiple fields with same key? think tags ..
PUT  /event/:id/field/:key
DEL  /event/:id/field/:key

--> getting events by type: "all events of type 'data'"
--> getting events within timeframe: "all events between datetime A and B"
```

__EVENT GROUPS__
```
GET  /event_groups

POST /event_group
GET  /event_group/:id
PUT  /event_group/:id
DEL  /event_group/:id

GET  /event_group/:id/events
	--> fields already included?
POST,PUT,DEL /event_group/:id/event
	--> add/update/remove event to/from group?
```