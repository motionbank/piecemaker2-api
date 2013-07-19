require 'spec_helper'

describe "Piecemaker::API Event" do
  include Rack::Test::Methods

  def app
    Piecemaker::API
  end

  before(:each) do
    truncate_db

    @peter = User.make :peter
    @pan = User.make :pan
    @hans_admin = User.make :hans_admin
    @klaus_disabled = User.make :klaus_disabled

    @alpha = EventGroup.make :alpha
    @beta = EventGroup.make :beta

    @big = Event.make :big, :event_group_id => @alpha.id

    @big_field = EventField.make :flag1, :event_id => @big.id

  end


  it "GET /api/v1/event/:id returns event with id" do
    header "X-Access-Key", @hans_admin.api_access_key
    get "/api/v1/event/#{@big.id}"
    last_response.status.should == 200
    json_parse(last_response.body).should == @big.values
  end

  describe "PUT /api/v1/event/:id", :focus do

    it "updates an event" do
      pending
    end

    it "updates an event and creates new fields" do
      pending
    end

    it "updates an event and updates existing fields" do
      pending
    end

    it "updates an event and deletes existing fields" do
      pending
    end

    it "updates an event with id" do
      header "X-Access-Key", @pan.api_access_key
      put "/api/v1/event/#{@big.id}", 
        :utc_timestamp => '6', 
        :duration => '7'
      last_response.status.should == 200
      returned = json_parse(last_response.body)

      returned_event = returned[0]
      event_from_database = Event.first(:id => returned_event[:id])
      event_from_database.values.should == returned_event
      
      returned_fields = returned[1]
      returned_fields.should =~ json_parse(@big.event_fields.to_json)

      # create event fields for additional params
      header "X-Access-Key", @pan.api_access_key
      put "/api/v1/event/#{@big.id}", 
        :utc_timestamp => '8', 
        :duration => '9',
        :fields => {
          :key1 => "some value",
          :another => "some more values"}
      last_response.status.should == 200

      returned = json_parse(last_response.body)

      returned_event = returned[0]
      @event_from_database = Event.first(:id => returned_event[:id])
      @event_from_database.values.should == returned_event

      returned_fields = returned[1]
      # @todo wtf? json_parse(...to_json) isnt there a dataset method for this?!
      event_fields_from_database_hash = json_parse(@event_from_database.event_fields.to_json)
      returned_fields.should_not eq([])
      returned_fields.should_not eq(nil)
      event_fields_from_database_hash.should =~ returned_fields

    end

  end

  it "DELETE /api/v1/event/:id deletes event with id" do
    header "X-Access-Key", @pan.api_access_key
    delete "/api/v1/event/#{@big.id}"
    last_response.status.should == 200
    Event.first(:id => @big.id).should eq(nil)
    EventField.where(:event_id => @big.id).count.should eq(0)
  end


end

