require 'spec_helper'

describe "Piecemaker::API Event" do
  include Rack::Test::Methods

  def app
    Piecemaker::API
  end

  before(:each) do
    truncate_db

  end

  it "POST /api/v1/event/:id/field creates a new field for event" do
    # alias 
    # POST AUTH /event/:event_id/field

    # create new field for event
    # Likes: token*, id*, value*
    # Returns: {id}
    raise
  end

  it "GET /api/v1/event/:id/field/:id returns field with id for event with id" do
    # alias 
    # get one field for event
    # Likes: token*
    # Returns: {value}
    raise
  end

  it "PUT /api/v1/event/:id/field/:id updates field with id for event with id" do
    # alias 
    # updates a field for an event
    # Likes: token*, value
    # Returns: boolean
    raise
  end

  it "DELETE /api/v1/event/:id/field/:id deletes field with id for event with id" do
    # alias 
    # delete one field for an event
    # Likes: token*
    # Returns: boolean
    raise
  end

end

