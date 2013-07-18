require 'spec_helper'

describe "Piecemaker::API User" do
  include Rack::Test::Methods

  def app
    Piecemaker::API
  end

  before(:all) do
    truncate_db
    
    @peter = User.make :peter
    @pan = User.make :pan
  end

  it "GET /api/v1/users returns all users" do
    get "/api/v1/users.json"
    last_response.status.should == 200
    last_response.body.should == [@peter, @pan].to_json
  end

  it "POST /api/v1/user/login returns new api access token on valid credentials", :focus do
    post "/api/v1/user/login", :email => @peter.email, :password => @peter.name
    last_response.status.should == 201
    json = JSON.parse(last_response.body)
    Piecemaker::Helper::API_Access_Key::makes_sense?(
      json["api_access_key"]).should eq(true)

    post "/api/v1/user/login", :email => @peter.email, :password => "wrong"
    last_response.status.should == 401

    post "/api/v1/user/login", :email => @peter.email, :password => ""
    last_response.status.should == 401

    post "/api/v1/user/login", :email => "", :password => ""
    last_response.status.should == 401

    post "/api/v1/user/login", :email => "", :password => @peter.name
    last_response.status.should == 401

    post "/api/v1/user/login", :email => "", :password => "random_wrong"
    last_response.status.should == 401

    post "/api/v1/user/login", :email => ""
    last_response.status.should == 400

    post "/api/v1/user/login", :password => ""
    last_response.status.should == 400

    post "/api/v1/user/login"
    last_response.status.should == 400

  end 

  it "POST /api/v1/user/logout invalidates the current api access token", :focus do
    request_with_api_access_key_from_user @peter
    post "/api/v1/user/logout"
    last_response.status.should == 201
    json = JSON.parse(last_response.body)
    json.should == {"api_access_key" => nil}

    header "X-Access-Key", "wrong"
    post "/api/v1/user/logout"
    last_response.status.should == 401

    header "X-Access-Key", ""
    post "/api/v1/user/logout"
    last_response.status.should == 401
  end


  it "POST /api/v1/user creates new user" do
    request_with_api_access_key_from_user @peter
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

