require 'spec_helper'

describe "Model UserRole" do

  before(:all) do
    truncate_db
    
    factory_batch do 
      @user_role_admin          = UserRole.make :admin
      @user_role_user           = UserRole.make :user
      @user_role_guest          = UserRole.make :guest

      @user_allow_read_item     = RolePermission.make :allow_read,
                                    :user_role_id => @user_role_user.id,
                                    :entity => "_awesome_item_xyz"

      @user_forbid_delete_item  = RolePermission.make :forbid_delete,
                                    :user_role_id => @user_role_user.id,
                                    :entity => "_awesome_item_xyz"


      @admin_allow_read_item    = RolePermission.make :allow_read,
                                    :user_role_id => @user_role_admin.id,
                                    :entity => "_awesome_item_xyz"

      @admin_allow_read_another_item = RolePermission.make :allow_read,
                                        :user_role_id => @user_role_admin.id,
                                        :entity => "_another_awesome_item_xyz"
        

      @pan                      = User.make :pan

      @event_group              = EventGroup.make :alpha

      @user_has_event_group     = UserHasEventGroup.make :default,
                                    :user_id => @pan.id,
                                    :event_group_id => @event_group.id,
                                    :user_role_id => @user_role_admin.id
    end

  end

  it "has many role permissions" do
    @user_role_admin.role_permissions.should =~ [@admin_allow_read_item, 
      @admin_allow_read_another_item]
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
