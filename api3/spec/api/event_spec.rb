require 'spec_helper'

describe "Piecemaker::API Event" do
  include Rack::Test::Methods
  def app
    Piecemaker::API
  end

  before(:each) do
    truncate_db

    factory_batch do 
      @peter          = User.make :peter
      @pan            = User.make :pan
      @hans_admin     = User.make :hans_admin
      @klaus_disabled = User.make :klaus_disabled

      @alpha          = EventGroup.make :alpha
      @beta           = EventGroup.make :beta

      @big            = Event.make :big, 
                          :event_group_id => @alpha.id

      @big_field      = EventField.make :flag1, 
                          :event_id => @big.id
    end
  end


  ##############################################################################
  describe "GET /api/v1/event/:id" do
  ##############################################################################

    #---------------------------------------------------------------------------
    it "returns event with id (and return fields and group as well)" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @hans_admin.api_access_key
      get "/api/v1/event/#{@big.id}"
      last_response.status.should == 200

      # returned event matches factory event?
      results       = json_string_to_hash(last_response.body)
      event         = results[:event]
      event_fields  = results[:fields]
      # event_group  = results[:group]

      event.should == @big.values
      event_fields.should =~ [@big_field.values]
      # event_group.should == @alpha.values
    end
    #---------------------------------------------------------------------------


    #-------------------------------------------------------------------------
    it "ACL auto-testing" do
    #-------------------------------------------------------------------------
      pending
      # get roles and test against this routes
    end
    #-------------------------------------------------------------------------
  end


  ##############################################################################
  describe "PUT /api/v1/event/:id" do
  ##############################################################################

    #---------------------------------------------------------------------------
    it "updates an event (without fields)" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @pan.api_access_key
      put "/api/v1/event/#{@big.id}", 
        :utc_timestamp => '6', 
        :duration => '7'
      last_response.status.should == 200

      result       = json_string_to_hash(last_response.body)
      event        = result[:event]
      event_fields = result[:fields]

      # returned event matches event in db?
      Event[event[:id]].values.should == event
      
      # returned event_fields match event_fields in db?
      event_fields.should =~ json_string_to_hash(@big.event_fields.to_json)
    end
    #---------------------------------------------------------------------------


    #---------------------------------------------------------------------------
    it "updates an event and creates new fields" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @pan.api_access_key
      put "/api/v1/event/#{@big.id}", 
        :utc_timestamp => '8', 
        :duration => '9',
        :fields => {
          :new_key => "some value",
          :another_new_key => "some more values"}
      last_response.status.should == 200
      
      result       = json_string_to_hash(last_response.body)
      event        = result[:event]
      event_fields = result[:fields]

      # returned event matches event in db?
      event.should == Event[event[:id]].values

      # returned event_fields match event_fields in db?
      event_fields.should == EventField.where(
        :event_id => event[:id]).all_values
    end
    #---------------------------------------------------------------------------

    #---------------------------------------------------------------------------
    it "updates an event and updates existing fields" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @pan.api_access_key
      put "/api/v1/event/#{@big.id}", 
        :utc_timestamp => '8', 
        :duration => '9',
        :fields => {
          :flag1 => "new value for flag1"}
      last_response.status.should == 200
      
      result       = json_string_to_hash(last_response.body)
      event        = result[:event]
      event_fields = result[:fields]

      # returned event matches event in db?
      event.should == Event[event[:id]].values

      # returned event_fields match event_fields in db?
      event_fields.should == EventField.where(
        :event_id => event[:id]).all_values
    end
    #---------------------------------------------------------------------------


    #---------------------------------------------------------------------------
    it "updates an event and deletes existing fields" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @pan.api_access_key
      put "/api/v1/event/#{@big.id}", 
        :utc_timestamp => '8', 
        :duration => '9',
        :fields => {
          :flag1 => "null"}
      last_response.status.should == 200
      
      result       = json_string_to_hash(last_response.body)
      event        = result[:event]
      event_fields = result[:fields]

      # returned event matches event in db?
      event.should == Event[event[:id]].values

      # returned event_fields match event_fields in db?
      event_fields.should == EventField.where(
        :event_id => event[:id]).all_values

      # event_field flag1 really deleted?
      EventField.first(
        :event_id => event[:id], 
        :id => "flag1").should eq(nil)
    end
    #---------------------------------------------------------------------------


    #-------------------------------------------------------------------------
    it "ACL auto-testing" do
    #-------------------------------------------------------------------------
      pending
      # get roles and test against this routes
    end
    #-------------------------------------------------------------------------
  end


  ##############################################################################
  describe "DELETE /api/v1/event/:id" do
  ##############################################################################

    #---------------------------------------------------------------------------
    it "deletes event with id" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @pan.api_access_key
      delete "/api/v1/event/#{@big.id}"
      last_response.status.should == 200

      # is the event really deleted from the db?
      Event.first(:id => @big.id).should eq(nil)

      # are the event_fields deleted as well?
      EventField.where(:event_id => @big.id).count.should eq(0)
    end
    #---------------------------------------------------------------------------


    #-------------------------------------------------------------------------
    it "ACL auto-testing" do
    #-------------------------------------------------------------------------
      pending
      # get roles and test against this routes
    end
    #-------------------------------------------------------------------------
  end

end