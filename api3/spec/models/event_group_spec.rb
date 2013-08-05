require 'spec_helper'

describe "Model EventGroup" do

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

  it "has many events" do
    @event_group.events.should == [@event]
  end

  it "has many users" do
    @event_group.users.should == [@pan]
  end


end

