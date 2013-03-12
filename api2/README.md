# API, v2

## Routes

### GET AUTH /event_groups
 * get all event_groups
 * Likes: ```token*```
 * Returns: ``[{id, title, text}]```

### POST AUTH /event_group
 * create new event_group
 * Likes: ```token*, title*, text```
 * Returns: ``{id}```

### GET AUTH /event_group/:id
 * get user details about one event_group
 * Likes: ```token*```
 * Returns: ``{id, title, text}```

### PUT AUTH /event_group/:id
 * updates a event_group
 * Likes: ```token*, title*, text```
 * Returns: ``boolean```

### DELETE AUTH /event_group/:id
 * delete one event_group
 * Likes: ```token*```
 * Returns: ``boolean```

### GET AUTH /event_group/:id/events
 * get all events for event_groups
 * Likes: ```token*```
 * Returns: ``[{id, event_group_id, event_group, created_by_user_id, created_by_user, utc_timestamp, duration}]```

### GET AUTH /event_group/:event_group_id/event/:event_id
 * get details about one event
 * Likes: ```token*```
 * Returns: ``{id, event_group_id, event_group, created_by_user_id, created_by_user, utc_timestamp, duration}```

### POST AUTH /event_group/:event_group_id/event
 * create new event and create new event_fields for all non-events table fields
 * Likes: ```token*, event_group_id, created_by_user_id, utc_timestamp, duration, ...```
 * Returns: ``{id}```

### PUT AUTH /event_group/:event_group_id/event/:event_id
 * updates a event
 * Likes: ```token*, event_group_id, created_by_user_id, utc_timestamp, duration```
 * Returns: ``boolean```

### DELETE AUTH /event_group/:event_group_id/event/:event_id
 * delete one event
 * Likes: ```token*```
 * Returns: ``boolean```

### GET AUTH /event_group/:event_group_id/events/type/:type
 * get events with type
 * Likes: ```token*```
 * Returns: ``[{id, event_group_id, event_group, created_by_user_id, created_by_user, utc_timestamp, duration}]```

### GET AUTH /event_group/:event_group_id/users
 * get all users for event_groups
 * Likes: ```token*```
 * Returns: ``[{id, name, email}]```

### GET /system/utc_timestamp
 * get unix timestamp with milliseconds
 * Likes: ``````
 * Returns: ``time```

### GET AUTH /users
 * get all users
 * Likes: ```token*```
 * Returns: ``[{id, name, email, is_admin}]```

### POST AUTH /user
 * create new user
 * Likes: ```token*, name*, email*```
 * Returns: ``{id}```

### GET AUTH /user/me
 * get user for api access key
 * Likes: ```*token```
 * Returns: ``{id, name, email, is_admin}```

### GET AUTH /user/:id
 * get user details about one user
 * Likes: ```token*```
 * Returns: ``{id, name, email, is_admin}```

### PUT AUTH /user/:id
 * updates a user
 * Likes: ```token*, name*, email*```
 * Returns: ``boolean```

### DELETE AUTH /user/:id
 * delete one user
 * Likes: ```token*```
 * Returns: ``boolean```

### GET AUTH /user/:id/event_groups
 * get all event_groups for user
 * Likes: ```token*```
 * Returns: ``[{id, title, text}]```

