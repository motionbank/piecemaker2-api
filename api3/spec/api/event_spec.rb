require 'spec_helper'

describe "Piecemaker::API Event" do
  include Rack::Test::Methods

  def app
    Piecemaker::API
  end

  before(:each) do
    truncate_db

  end


  it "GET /api/v1/event/:id alias for /api/v1/event/:id" do
    pending
    # get details about one event
    # Likes: token*
    # Returns: {id, event_group_id, event_group, created_by_user_id, created_by_user, utc_timestamp, duration}
  end

  it "POST /api/v1/event/:id creates new event and event_fields" do
    pending
    # create new event and create new event_fields for all non-events table fields
    # Likes: token*, utc_timestamp, duration, ...
    # Returns: {id}
  end

  it "PUT /api/v1/event/:id updates an event with id" do
    pending
    # updates a event
    # Likes: token*, utc_timestamp, duration
    # Returns: boolean
  end

  it "DELETE /api/v1/event/:id deletes event with id" do
    pending
    # delete one event
    # Likes: token*
    # Returns: boolean
  end

  


  it "POST /api/v1/event/:id/field creates a new field for event" do
    # alias 
    # POST AUTH /event/:event_id/field

    # create new field for event
    # Likes: token*, id*, value*
    # Returns: {id}
    pending
  end

  it "GET /api/v1/event/:id/field/:id returns field with id for event with id" do
    # alias 
    # get one field for event
    # Likes: token*
    # Returns: {value}
    pending
  end

  it "PUT /api/v1/event/:id/field/:id updates field with id for event with id" do
    # alias 
    # updates a field for an event
    # Likes: token*, value
    # Returns: boolean
    pending
  end

  it "DELETE /api/v1/event/:id/field/:id deletes field with id for event with id" do
    # alias 
    # delete one field for an event
    # Likes: token*
    # Returns: boolean
    pending
  end



end

