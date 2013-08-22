require 'spec_helper'

describe "Model RolePermission" do

  before(:all) do
    truncate_db
    
    factory_batch do 
      @user_role_admin          = UserRole.make :admin
      @user_role_user           = UserRole.make :user

      @user_allow_read_item     = RolePermission.make :allow_read,
                                    :user_role_id => @user_role_user.id,
                                    :entity => "_awesome_item_xyz"

      @user_forbid_delete_item  = RolePermission.make :forbid_delete,
                                    :user_role_id => @user_role_user.id,
                                    :entity => "_awesome_item_xyz"
    end

  end

  it "has one user role" do
    @user_allow_read_item.user_role.should == @user_role_user
  end

end
