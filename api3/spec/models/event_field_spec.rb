require 'spec_helper'

describe EventField do

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

  it "has one event" do
    @event_field.event.should == @event
  end



end

