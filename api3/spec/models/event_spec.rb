require 'spec_helper'

describe Event do

  before(:all) do
    truncate_db
    
    @pan = User.make :pan

    @event_group = EventGroup.make :alpha

    @event = Event.make :big, 
      :event_group_id => @event_group.id,
      :created_by_user_id => @pan.id
    
    @event_field = EventField.make :flag1,
      :event_id => @event.id
  end

  it "has one user" do
    @event.user.to_json.should == @pan.to_json
  end

  it "has many event fields" do
    @event.event_fields.to_json.should == [@event_field].to_json
  end

  it "has one event group" do
    @event.event_group.to_json.should == @event_group.to_json
  end

end

