require 'spec_helper'

describe "Model UserHasEventGroup" do

  before(:all) do
    truncate_db

    factory_batch do 
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
  end

  it "has one user" do
    @user_has_event_group.user.should == @pan
  end

  it "has one event group" do
    @user_has_event_group.event_group.should == @event_group
  end


end

