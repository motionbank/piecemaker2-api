require 'spec_helper'

describe "Model RolePermission" do

  before(:all) do
    truncate_db
    
    factory_batch do 
      @user_role_user           = UserRole.make :user

      @user_allow_read_item     = RolePermission.make :allow,
                                    :user_role_id => @user_role_user.id
    end

  end

  it "has one user role" do
    @user_allow_read_item.user_role.should == @user_role_user
  end

end
