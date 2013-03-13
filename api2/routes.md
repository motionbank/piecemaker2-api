__POST AUTH /event/:event_id/field__
 * create new field for event
 * Likes: ```token*, id*, value*```
 * Returns: ```{id}```
  
__GET AUTH /event/:event_id/field/:field_id__
 * get one field for event
 * Likes: ```token*```
 * Returns: ```{value}```
  
__PUT AUTH /event/:event_id/field/:field_id__
 * updates a field for an event
 * Likes: ```token*, value```
 * Returns: ```boolean```
  
__DELETE AUTH /event/:event_id/field/:field_id__
 * delete one field for an event
 * Likes: ```token*```
 * Returns: ```boolean```
  
__GET AUTH /groups__
 * get all event_groups
 * Likes: ```token*```
 * Returns: ```[{id, title, text}]```
  
__POST AUTH /group__
 * create new event_group
 * Likes: ```token*, title*, text```
 * Returns: ```{id}```
  
__GET AUTH /group/:id__
 * get user details about one event_group
 * Likes: ```token*```
 * Returns: ```{id, title, text}```
  
__PUT AUTH /group/:id__
 * updates a event_group
 * Likes: ```token*, title*, text```
 * Returns: ```boolean```
  
__DELETE AUTH /group/:id__
 * delete one event_group
 * Likes: ```token*```
 * Returns: ```boolean```
  
__GET AUTH /group/:id/events__
 * get all events for event_groups
 * Likes: ```token*```
 * Returns: ```[{id, event_group_id, event_group, created_by_user_id, created_by_user, utc_timestamp, duration}]```
  
__GET AUTH /group/:event_group_id/event/:event_id__
 * get details about one event
 * Likes: ```token*```
 * Returns: ```{id, event_group_id, event_group, created_by_user_id, created_by_user, utc_timestamp, duration}```
  
__POST AUTH /group/:event_group_id/event__
 * create new event and create new event_fields for all non-events table fields
 * Likes: ```token*, created_by_user_id, utc_timestamp, duration, ...```
 * Returns: ```{id}```
  
__PUT AUTH /group/:event_group_id/event/:event_id__
 * updates a event
 * Likes: ```token*, created_by_user_id, utc_timestamp, duration```
 * Returns: ```boolean```
  
__DELETE AUTH /group/:event_group_id/event/:event_id__
 * delete one event
 * Likes: ```token*```
 * Returns: ```boolean```
  
__GET AUTH /group/:event_group_id/events/by_type/:type__
 * get events with type
 * Likes: ```token*```
 * Returns: ```[{id, event_group_id, event_group, created_by_user_id, created_by_user, utc_timestamp, duration}]```
  
__GET AUTH /group/:event_group_id/users__
 * get all users for event_groups
 * Likes: ```token*```
 * Returns: ```[{id, name, email}]```
  
__GET /system/utc_timestamp__
 * get unix timestamp with milliseconds
 * Likes: ``````
 * Returns: ```time```
  
__GET AUTH /users__
 * get all users
 * Likes: ```token*```
 * Returns: ```[{id, name, email, is_admin}]```
  
__POST AUTH /user__
 * create new user
 * Likes: ```token*, name*, email*```
 * Returns: ```{id}```
  
__GET AUTH /user/me__
 * get user for api access key
 * Likes: ```token*```
 * Returns: ```{id, name, email, is_admin}```
  
__GET AUTH /user/:id__
 * get user details about one user
 * Likes: ```token*```
 * Returns: ```{id, name, email, is_admin}```
  
__PUT AUTH /user/:id__
 * updates a user
 * Likes: ```token*, name*, email*```
 * Returns: ```boolean```
  
__DELETE AUTH /user/:id__
 * delete one user
 * Likes: ```token*```
 * Returns: ```boolean```
  
__GET AUTH /user/:id/event_groups__
 * get all event_groups for user
 * Likes: ```token*```
 * Returns: ```[{id, title, text}]```
  
