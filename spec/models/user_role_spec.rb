require 'spec_helper'

describe "Model UserRole" do

  before(:all) do
    truncate_db
    
    factory_batch do 

      action_prefix = "__some_random_SURY24259_chars_"

      @user_role_admin     = UserRole.make :admin
      @user_role_user      = UserRole.make :user
      @user_role_guest     = UserRole.make :guest


      @admin_allow_a       = RolePermission.make :allow,
                              :user_role_id => @user_role_admin.id,
                              :action => action_prefix + "a"

      @admin_allow_b       = RolePermission.make :allow,
                              :user_role_id => @user_role_admin.id,
                              :action => action_prefix + "b"
        

      @pan                 = User.make :pan

      @event_group         = EventGroup.make :alpha,
                              :created_by_user_id => @pan.id

      @user_has_event_group = UserHasEventGroup.make :default,
                                :user_id => @pan.id,
                                :event_group_id => @event_group.id,
                                :user_role_id => @user_role_admin.id
    end

  end

  it "has many role permissions" do
    @user_role_admin.role_permissions.should =~ [@admin_allow_a, 
      @admin_allow_b]
  end

  it "has no role permissions" do
    @user_role_guest.role_permissions.should == []
  end

  it "has many user has event groups" do
    @user_role_admin.user_has_event_groups.should =~ [@user_has_event_group]
  end

  it "has no user has event groups" do
    @user_role_user.user_has_event_groups.should == []
  end

end
