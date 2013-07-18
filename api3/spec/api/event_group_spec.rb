require 'spec_helper'

describe "Piecemaker::API EventGroup" do
  include Rack::Test::Methods

  def app
    Piecemaker::API
  end

  before(:all) do
    truncate_db

  end

  it "GET /api/v1/groups returns all event_groups for currently logged in user" do
    raise
    # get all event_groups for current user (with read rights)
    # Likes: token*
    # Returns: [{id, title, text}]
  end

  it "POST /api/v1/group create new event_group (and user_has_event_group record)" do
    raise
    # create new event_group and record for user_has_event_groups (allow everything for owner of event_group)
    # Likes: token*, title*, text
    # Returns: {id}
  end

  it "GET /api/v1/group/:id returns event_group with id" do
    raise
    # get user details about one event_group
    # Likes: token*
    # Returns: {id, title, text}
  end

  it "PUT /api/v1/group/:id updates event_group with id" do
    raise
    # updates a event_group
    # Likes: token*, title*, text
    # Returns: boolean

  end

  it "DELETE /api/v1/group/:id deletes event_group with id" do
    raise
    # delete one event_group
    # Likes: token*
    # Returns: boolean
  end

  it "GET /api/v1/group/:id/events returns all events \
    (with event_fields) for event_group with id" do
    raise
    # get all events for event_groups, add vars (utc_timestamp, duration, type and other fields from event_fields) to filter
    # Likes: token*
    # Returns: [{id, event_group_id, event_group, created_by_user_id, created_by_user, utc_timestamp, duration}]
  end

  it "GET /api/v1/group/:id/event/:id alias for /api/v1/event/:id" do
    raise
    # get details about one event
    # Likes: token*
    # Returns: {id, event_group_id, event_group, created_by_user_id, created_by_user, utc_timestamp, duration}
  end

  it "POST /api/v1/group/:id/event/:id creates new event and event_fields" do
    raise
    # create new event and create new event_fields for all non-events table fields
    # Likes: token*, utc_timestamp, duration, ...
    # Returns: {id}
  end

  it "PUT /api/v1/group/:id/event/:id updates an event with id" do
    raise
    # updates a event
    # Likes: token*, utc_timestamp, duration
    # Returns: boolean
  end

  it "DELETE /api/v1/group/:id/event/:id deletes event with id" do
    raise
    # delete one event
    # Likes: token*
    # Returns: boolean
  end

  it "GET /api/v1/group/:id/event/by_type/:type returns events by type" do
    raise
    # get events with type
    # Likes: token*
    # Returns: [{id, event_group_id, event_group, created_by_user_id, created_by_user, utc_timestamp, duration}]

  end

  it "GET /api/v1/group/:id/users returns all users for event_group with id" do
    raise
    # get all users for event_groups
    # Likes: token*
    # Returns: [{id, name, email}]
  end

end

