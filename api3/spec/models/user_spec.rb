require 'spec_helper'

describe User do

  before(:each) do
    truncate_db
    @pan = User.make :pan

    @event_group = EventGroup.make :alpha
    @event = Event.make :big, 
      :event_group_id => @event_group.id,
      :created_by_user_id => @pan.id
    
  end

  it "has many events" do
    @pan.events.to_json.should == [@event].to_json
  end

end

