require 'spec_helper'

describe "Model Event" do

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
    end
  end

  it "has one user" do
    @event.user.should == @pan
  end

  it "has many event fields" do
    @event.event_fields.should == [@event_field]
  end

  it "has one event group" do
    @event.event_group.should == @event_group
  end

end

