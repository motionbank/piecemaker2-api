require 'spec_helper'

describe "Piecemaker::API EventGroup" do
  include Rack::Test::Methods
  def app
    Piecemaker::API
  end

  before(:each) do
    truncate_db

    factory_batch do 

      @peter                = User.make :peter
      @pan                  = User.make :pan
      @hans_admin           = User.make :hans_admin
    
      # create alpha BEFORE beta for "ordered by" specs
      @alpha                = EventGroup.make :alpha, 
                                :created_by_user_id => @hans_admin.id
      @beta                 = EventGroup.make :beta,
                                :created_by_user_id => @hans_admin.id
    
      # create big_in_alpha BEFORE small_in_alpha for "ordered by" specs
      @big_in_alpha         = Event.make :big, 
                                :event_group_id => @alpha.id
      @small_in_alpha       = Event.make :small, 
                                :event_group_id => @alpha.id

      @small_event_field    = EventField.make :flag1,
                                :event_id => @small_in_alpha.id

      @pan_has_event_group_alpha  = UserHasEventGroup.make :default,  
                                :user_id => @pan.id, 
                                :event_group_id => @alpha.id

      @pan_has_event_group_beta  = UserHasEventGroup.make :default,  
                                :user_id => @pan.id, 
                                :event_group_id => @beta.id

      @hans_has_event_group = UserHasEventGroup.make :default,  
                                :user_id => @hans_admin.id, 
                                :event_group_id => @alpha.id

      @flag1_field          = EventField.make :flag1,
                                :event_id => @big_in_alpha.id


      # create z_field BEFORE a_field for "ordered by" specs
      @z_field              = EventField.make :z,
                                :event_id => @big_in_alpha.id
      @a_field              = EventField.make :a,
                                :event_id => @big_in_alpha.id


      @user_role_admin      = UserRole.make :admin

    end
  end


  ##############################################################################
  describe "GET /api/v1/groups" do
  ##############################################################################

    #---------------------------------------------------------------------------
    it "returns all event_groups for currently logged in user" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @pan.api_access_key
      get "/api/v1/groups"
      last_response.status.should == 200

      json_string_to_hash(last_response.body)
        .should =~ times_to_s([@alpha.values, @beta.values])
    end
    #---------------------------------------------------------------------------
  end


  ##############################################################################
  describe "POST /api/v1/group/:id/event" do
  ##############################################################################

    #---------------------------------------------------------------------------
    it "creates and returns new event (without additional event_fields)" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @hans_admin.api_access_key
      post "/api/v1/group/#{@alpha.id}/event", 
        :utc_timestamp => '1.0', 
        :duration => '2.0',
        :type => 'my_type'
      last_response.status.should == 201

      result       = json_string_to_hash(last_response.body)
      event        = result[:event]
      event_fields = result[:fields]

      # was the event created?
      Event[event[:id]].values.should == event

      # do the values match?
      event[:utc_timestamp].should == 1.0
      event[:duration].should == 2.0
      event[:type].should == 'my_type'
      
      # no event_fields should be created!
      event_fields.should eq([])
    end
    #---------------------------------------------------------------------------


    #---------------------------------------------------------------------------
    it "creates and returns new event (with additional event_fields)" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @hans_admin.api_access_key
      post "/api/v1/group/#{@alpha.id}/event", 
        :utc_timestamp => '3.0', 
        :duration => '4.0',
        :type => 'my_type',
        :fields => {
          :key1 => "some value",
          :another => "some more values"}
      last_response.status.should == 201

      result       = json_string_to_hash(last_response.body)
      event        = result[:event]
      event_fields = result[:fields]

      # was the event created?
      Event[event[:id]].values.should == event

      # are event_fields passed?
      event_fields.should_not eq([])
      event_fields.should_not eq(nil)
      event_fields.should_not eq("")

      # have the event_fields been saved?
      event_fields.should =~ EventField.where(
        :event_id => event[:id]).all_values
    end
    #---------------------------------------------------------------------------


    #---------------------------------------------------------------------------
    it "fails if key for event_field is too long" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @hans_admin.api_access_key
      post "/api/v1/group/#{@alpha.id}/event", 
        :utc_timestamp => '3', 
        :duration => '4',
        :type => 'my_type',
        :fields => {
          :key1___________________________________________________ => "content",
          :another => "some more values"}
      last_response.status.should == 400
    end
    #---------------------------------------------------------------------------
    
  end


  ##############################################################################
  describe "POST /api/v1/group" do
  ##############################################################################
    
    #---------------------------------------------------------------------------
    it "create new event_group (together with user_has_event_groups record)" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @hans_admin.api_access_key
      post "/api/v1/group", :title => "Omega", :text => "Text for Omega"
      last_response.status.should == 201
      
      returned_omega = json_parse(last_response.body)
      @omega_from_database = EventGroup.first(:id => returned_omega[:id])
      returned_omega.should == times_to_s(@omega_from_database.values)

      # is the new event_group linked to users via user_has_event_groups?
      UserHasEventGroup.first(:user_id => @hans_admin.id, 
        :event_group_id => returned_omega[:id]).should_not eq(nil)
    end
    #---------------------------------------------------------------------------

    #---------------------------------------------------------------------------
    it "makes the currently logged in user the owner" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @hans_admin.api_access_key
      post "/api/v1/group", :title => "Omega", :text => "Text for Omega"
      last_response.status.should == 201

      returned_omega = json_parse(last_response.body)
      returned_omega[:created_by_user_id].should == @hans_admin.id
    end
    #---------------------------------------------------------------------------

    it "assigns admin-like role to owner of event group" do
      pending "waiting for role definitions (what is an admin-like role?)"
    end

  end


  ##############################################################################
  describe "GET /api/v1/group/:id" do
  ##############################################################################

    #---------------------------------------------------------------------------
    it "returns event_group with id" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @hans_admin.api_access_key
      get "/api/v1/group/#{@alpha.id}"
      last_response.status.should == 200
      json_string_to_hash(last_response.body)
        .should == times_to_s(@alpha.values)
    end
    #---------------------------------------------------------------------------
  end


  ##############################################################################
  describe "PUT /api/v1/group/:id" do
  ##############################################################################
    
    #---------------------------------------------------------------------------
    it "updates event_group with id" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @hans_admin.api_access_key
      put "/api/v1/group/#{@alpha.id}", :title => "Omega", 
        :text => "Text for Omega"
      last_response.status.should == 200

      event_group = json_string_to_hash(last_response.body)
      event_group.should == times_to_s(EventGroup.first(
        :id => event_group[:id]).values)
    end
    #---------------------------------------------------------------------------
  end


  ##############################################################################
  describe "DELETE /api/v1/group/:id" do
  ##############################################################################
    
    #---------------------------------------------------------------------------
    it "deletes event_group with id" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @hans_admin.api_access_key
      delete "/api/v1/group/#{@alpha.id}"
      last_response.status.should == 200
      EventGroup.first(:id => @alpha.id).should eq(nil)
    end
    #---------------------------------------------------------------------------

    #---------------------------------------------------------------------------
    it "make sure there is at least ony user that has delete permissions" +
       " before deleting" do
    #---------------------------------------------------------------------------
      pending "waiting for role definitions"
    end
    #---------------------------------------------------------------------------
  end


  ##############################################################################
  describe "GET /api/v1/group/:id/events" do
  ##############################################################################
    
    #---------------------------------------------------------------------------
    it "returns all events (with event_fields) for event_group with id" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @hans_admin.api_access_key
      get "/api/v1/group/#{@alpha.id}/events"
      last_response.status.should == 200

      results       = json_string_to_hash(last_response.body)
      results.should_not eq([])
      results.should_not eq(nil)

      results.should =~ [
        {
          :event => @big_in_alpha.values, 
          :fields => [@a_field.values, @flag1_field.values, 
                      @z_field.values]
        }, 
        {
          :event => @small_in_alpha.values,
          :fields => []
        }
      ]
    end
    #---------------------------------------------------------------------------

    #---------------------------------------------------------------------------
    it "fails if the events are not ordered by utc_timestamp ASC" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @hans_admin.api_access_key
      get "/api/v1/group/#{@alpha.id}/events"
      last_response.status.should == 200

      results        = json_string_to_hash(last_response.body)
      event_0        = results[0][:event]
      event_1        = results[1][:event]

      event_0.should == @small_in_alpha.values
      event_1.should == @big_in_alpha.values
    end
    #---------------------------------------------------------------------------

    #---------------------------------------------------------------------------
    it "fails if the event fields are not ordered id ASC" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @hans_admin.api_access_key
      get "/api/v1/group/#{@alpha.id}/events"
      last_response.status.should == 200

      results        = json_string_to_hash(last_response.body)
      event_fields_1 = results[1][:fields]

      event_fields_1.should == [@a_field.values, @flag1_field.values, 
                      @z_field.values]
    end
    #---------------------------------------------------------------------------
  end


  ##############################################################################
  describe "GET /api/v1/group/:id/events" +
           "?from=<utc_timestamp>&to=<utc_timestamp>" do
  ##############################################################################
    
    #---------------------------------------------------------------------------
    it "returns all events between time frame" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @hans_admin.api_access_key
      get "/api/v1/group/#{@alpha.id}/events?from=0&to=10"
      last_response.status.should == 200

      results       = json_string_to_hash(last_response.body)

      results.should =~ [
        {
          :event => @small_in_alpha.values, 
          :fields => []
        }
      ]
    end
    #---------------------------------------------------------------------------
  end


  ##############################################################################
  describe "GET /api/v1/group/:id/events" +
           "?field[key]=value" do
  ##############################################################################
   
    #---------------------------------------------------------------------------
    it "returns all events filtered by event type" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @hans_admin.api_access_key
      get "/api/v1/group/#{@alpha.id}/events?type=big"
      last_response.status.should == 200

      results       = json_string_to_hash(last_response.body)

      results.should =~ [
        {
          :event => @big_in_alpha.values, 
          :fields => [@a_field.values, @flag1_field.values, 
                      @z_field.values]
        }
      ]

    end
    #---------------------------------------------------------------------------

    #---------------------------------------------------------------------------
    it "returns all events filtered by multiple fields" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @hans_admin.api_access_key
      get "/api/v1/group/#{@alpha.id}/events?type=big" + 
          "&field[flag1]=getting%20back%20to%20the%20dolphin%20thing" +
          "&field[z]=flag%20with%20id%20z"
      last_response.status.should == 200

      results       = json_string_to_hash(last_response.body)

      results.should =~ [
        {
          :event => @big_in_alpha.values, 
          :fields => [@a_field.values, @flag1_field.values, 
                      @z_field.values]
        }
      ]

    end
    #---------------------------------------------------------------------------

    #---------------------------------------------------------------------------
    it "returns empty array for non existing type" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @hans_admin.api_access_key
      get "/api/v1/group/#{@alpha.id}/events?type=i_dont_exist"
      last_response.status.should == 200

      results = json_string_to_hash(last_response.body)
      results.should =~ []
    end
    #---------------------------------------------------------------------------
  end


  ##############################################################################
  describe "GET /api/v1/group/:id/users" do
  ##############################################################################
    
    #---------------------------------------------------------------------------
    it "returns all users for event_group with id" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @hans_admin.api_access_key
      get "/api/v1/group/#{@alpha.id}/users"
      last_response.status.should == 200
      json_string_to_hash(last_response.body).should =~ [@pan.values, 
        @hans_admin.values]
    end
    #---------------------------------------------------------------------------
  end


  ##############################################################################
  describe "POST /api/v1/group/:id/user/:id" do
  ##############################################################################
    
    #---------------------------------------------------------------------------
    it "adds a user to an event_group (via user_has_event_groups) " +
       "and set user_role_id" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @hans_admin.api_access_key
      post "/api/v1/group/#{@alpha.id}/user/#{@peter.id}", 
        :user_role_id => @user_role_admin.id
      last_response.status.should == 201

      result       = json_string_to_hash(last_response.body)
      result.should == {:status => true}

      @user_has_event_group = UserHasEventGroup.first(
        :user_id => @peter.id, 
        :event_group_id => @alpha.id)

      @user_has_event_group.should_not eq(nil)
      @user_has_event_group.user_role_id.should == @user_role_admin.id

    end
    #---------------------------------------------------------------------------


    #---------------------------------------------------------------------------
    it "adds a user to an event_group (via user_has_event_groups) " +
       "and set empty user_role_id" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @hans_admin.api_access_key
      post "/api/v1/group/#{@alpha.id}/user/#{@peter.id}"
      last_response.status.should == 201

      result       = json_string_to_hash(last_response.body)
      result.should == {:status => true}

      @user_has_event_group = UserHasEventGroup.first(
        :user_id => @peter.id, 
        :event_group_id => @alpha.id)

      @user_has_event_group.should_not eq(nil)
      @user_has_event_group.user_role_id.should == nil
    end
    #---------------------------------------------------------------------------


    #---------------------------------------------------------------------------
    it "adds a user to an event_group (via user_has_event_groups) " +
       "and set invalid user_role_id" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @hans_admin.api_access_key
      post "/api/v1/group/#{@alpha.id}/user/#{@peter.id}",
        :user_role_id => "non_existing_role_h42kj42kjkSDFsfq44_24%§$%"
      last_response.status.should == 404
    end
    #---------------------------------------------------------------------------
  end



  ##############################################################################
  describe "PUT /api/v1/group/:id/user/:id" do
  ##############################################################################
    
    #---------------------------------------------------------------------------
    it "updates user_role_id in user_has_event_groups with valid id" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @hans_admin.api_access_key
      put "/api/v1/group/#{@alpha.id}/user/#{@pan.id}",
        :user_role_id => @user_role_admin.id
      last_response.status.should == 200

      user_has_event_group = json_string_to_hash(last_response.body)
      
      @user_has_event_group = UserHasEventGroup.first(
        :user_id => @pan.id, 
        :event_group_id => @alpha.id)

      @user_has_event_group.values.should == user_has_event_group
    end
    #---------------------------------------------------------------------------


    #---------------------------------------------------------------------------
    it "updates user_role_id in user_has_event_groups with empty id" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @hans_admin.api_access_key
      put "/api/v1/group/#{@alpha.id}/user/#{@pan.id}"
      last_response.status.should == 200

      user_has_event_group = json_string_to_hash(last_response.body)

      @user_has_event_group = UserHasEventGroup.first(
        :user_id => @pan.id, 
        :event_group_id => @alpha.id)

      @user_has_event_group.should_not eq(nil)
      @user_has_event_group.user_role_id.should eq(nil)
    end
    #---------------------------------------------------------------------------


    #---------------------------------------------------------------------------
    it "updates user_role_id in user_has_event_groups with invalid id" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @hans_admin.api_access_key
      put "/api/v1/group/#{@alpha.id}/user/#{@peter.id}",
        :user_role_id => "non_existing_role_h42kj42kjkSDFsfq44_24%§$%"
      last_response.status.should == 404
    end
    #---------------------------------------------------------------------------
  end



  ##############################################################################
  describe "DELETE /api/v1/group/:id/user/:id" do
  ##############################################################################
    
    #---------------------------------------------------------------------------
    it "deletes a user from an event_group (via user_has_event_groups)" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @hans_admin.api_access_key
      delete "/api/v1/group/#{@alpha.id}/user/#{@peter.id}"
      last_response.status.should == 200

      result       = json_string_to_hash(last_response.body)
      result.should == {:status => true}

      UserHasEventGroup.first(:user_id => @peter.id, 
        :event_group_id => @alpha.id).should eq(nil)
    end
    #---------------------------------------------------------------------------
  end

end