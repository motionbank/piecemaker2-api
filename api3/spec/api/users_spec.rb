require 'spec_helper'

describe "Piecemaker::API User" do
  include Rack::Test::Methods

  def app
    Piecemaker::API
  end

  before(:all) do
    @peter = User.make :peter
    @pan = User.make :pan
  end

  it "GET /api/v1/users returns all users" do
    get "/api/v1/users.json"
    last_response.status.should == 200
    last_response.body.should == [@peter, @pan].to_json
  end

  it "POST /api/v1/user creates new user" do
    raise
  end

  it "GET /api/v1/user/me returns currently logged in user" do
    raise
  end

  it "GET /api/v1/user/:id returns user for id" do
    raise
  end

  it "PUT /api/v1/user/:id updates user with id" do
    raise
  end

  it "DELETE /api/v1/user/:id deletes user with id" do
    raise
  end

  it "GET /api/v1/user/:id/event_groups returns all event_groups for user with id" do
    raise
  end

end

