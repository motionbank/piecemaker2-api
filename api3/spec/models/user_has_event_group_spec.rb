require 'spec_helper'

describe UserHasEventGroup do

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

  it "has one user" do
    @user_has_event_group.user.to_json.should == @pan.to_json
  end

  it "has one event group" do
    @user_has_event_group.event_group.to_json.should == @event_group.to_json
  end


end

