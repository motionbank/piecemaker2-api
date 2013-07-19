require 'spec_helper'

describe "Piecemaker::API EventGroup" do
  include Rack::Test::Methods

  def app
    Piecemaker::API
  end

  before(:each) do
    truncate_db

    @peter = User.make :peter
    @pan = User.make :pan
    @hans_admin = User.make :hans_admin

    @alpha = EventGroup.make :alpha
    @beta = EventGroup.make :beta

    @big_in_alpha = Event.make :big, :event_group_id => @alpha.id

    @pan_has_event_group = UserHasEventGroup.make :default,  
      :user_id => @pan.id, :event_group_id => @alpha.id

    @hans_has_event_group = UserHasEventGroup.make :default,  
      :user_id => @hans_admin.id, :event_group_id => @alpha.id
  end

  it "GET /api/v1/groups returns all event_groups for currently logged in user" do
    header "X-Access-Key", @pan.api_access_key
    get "/api/v1/groups"
    last_response.status.should == 200
    json_parse(last_response.body).should =~ [@alpha.values, @beta.values]
  end

  it "POST /api/v1/group create new event_group \ 
    (together with user_has_event_groups record)" do
    header "X-Access-Key", @pan.api_access_key
    post "/api/v1/group", :title => "Omega", :text => "Text for Omega"
    last_response.status.should == 201
    
    returned_omega = json_parse(last_response.body)
    @omega_from_database = EventGroup.first(:id => returned_omega[:id])
    returned_omega.should == @omega_from_database.values

    UserHasEventGroup.first(:user_id => @pan.id, 
      :event_group_id => returned_omega[:id]).should_not eq(nil)

  end

  it "GET /api/v1/group/:id returns event_group with id" do
    header "X-Access-Key", @pan.api_access_key
    get "/api/v1/group/#{@alpha.id}"
    last_response.status.should == 200
    json_parse(last_response.body).should == @alpha.values
  end

  it "PUT /api/v1/group/:id updates event_group with id" do
    header "X-Access-Key", @pan.api_access_key
    put "/api/v1/group/#{@alpha.id}", :title => "Omega", 
      :text => "Text for Omega"
    last_response.status.should == 200
    returned_alpha = json_parse(last_response.body)
    returned_alpha.should == EventGroup.first(:id => returned_alpha[:id]).values
  end

  it "DELETE /api/v1/group/:id deletes event_group with id" do
    header "X-Access-Key", @pan.api_access_key
    delete "/api/v1/group/#{@alpha.id}"
    last_response.status.should == 200
    EventGroup.first(:id => @alpha.id).should eq(nil)
  end

  it "GET /api/v1/group/:id/events returns all events \
    (with event_fields) for event_group with id" do
    header "X-Access-Key", @pan.api_access_key
    get "/api/v1/group/#{@alpha.id}/events"
    last_response.status.should == 200
    json_parse(last_response.body).should == [@big_in_alpha.values]
  end

  it "GET /api/v1/group/:id/users returns all \
    users for event_group with id" do
    header "X-Access-Key", @pan.api_access_key
    get "/api/v1/group/#{@alpha.id}/users"
    last_response.status.should == 200
    json_parse(last_response.body).should =~ [@hans_admin.values, @pan.values]
  end

  it "GET /api/v1/group/:id/event/by_type/:type returns events by type" do
    raise
    # get events with type
    # Likes: token*
    # Returns: [{id, event_group_id, event_group, created_by_user_id, created_by_user, utc_timestamp, duration}]
  end


end

