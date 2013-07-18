require 'spec_helper'

describe EventGroup do

  before(:all) do
    truncate_db
    
    @pan = User.make :pan

    @event_group = EventGroup.make :alpha

    @event = Event.make :big, 
      :event_group_id => @event_group.id,
      :created_by_user_id => @pan.id
    
    @event_field = EventField.make :flag1,
      :event_id => @event.id

    @user_has_event_group = UserHasEventGroup.make :default,
      :user_id => @pan.id,
      :event_group_id => @event_group.id
  end

  it "has many events" do
    @event_group.events.to_json.should == [@event].to_json
  end

  it "has many users" do
    @event_group.users.to_json.should == [@pan].to_json
  end


end

