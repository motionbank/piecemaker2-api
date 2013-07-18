require 'spec_helper'

describe User do

  before(:all) do
    truncate_db
    
    @pan = User.make :pan

    @event_group = EventGroup.make :alpha

    @event = Event.make :big, 
      :event_group_id => @event_group.id,
      :created_by_user_id => @pan.id
    
    @user_has_event_group = UserHasEventGroup.make :default,
      :user_id => @pan.id,
      :event_group_id => @event_group.id
  end

  it "has many events" do
    @pan.events.should == [@event]
  end

  it "has many event_groups" do
    @pan.event_groups.should == [@event_group]
  end

end

