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

  # --------------------------------------------------
  describe "PUT /api/v1/event/:id", :focus do

    it "updates an event (without fields)" do
      header "X-Access-Key", @pan.api_access_key
      put "/api/v1/event/#{@big.id}", 
        :utc_timestamp => '6', 
        :duration => '7'
      last_response.status.should == 200

      result = json_string_to_hash(last_response.body)

      # returned event matches event in db?
      event = result[0]
      Event.first(:id => event[:id]).values.should == event
      
      # returned event_fields match event_fields in db?
      event_fields = result[1]
      event_fields.should =~ json_parse(@big.event_fields.to_json)
    end

    it "updates an event and creates new fields" do
      header "X-Access-Key", @pan.api_access_key
      put "/api/v1/event/#{@big.id}", 
        :utc_timestamp => '8', 
        :duration => '9',
        :fields => {
          :new_key => "some value",
          :another_new_key => "some more values"}
      last_response.status.should == 200
      
      result = json_string_to_hash(last_response.body)
      event = result[0]
      event_fields = result[1]

      event.should == Event[event[:id]].values

      event_fields.should == EventField.where(
        :event_id => event[:id]).all_values

    end

    it "updates an event and updates existing fields" do
      pending
    end

    it "updates an event and deletes existing fields" do
      pending
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

