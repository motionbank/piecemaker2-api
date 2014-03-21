require 'spec_helper'

describe "Piecemaker::API UserRole" do
  include Rack::Test::Methods
  def app
    Piecemaker::API
  end

  before(:each) do
    truncate_db

    factory_batch do 
      @frank_super_admin   = User.make :frank_super_admin
      
      @user_role_admin     = UserRole.make :admin
      @user_role_user      = UserRole.make :user
      @user_role_guest     = UserRole.make :guest

      @permission1         = RolePermission.make :allow,
                              :user_role_id => @user_role_admin.id

    end
  end


  ##############################################################################
  describe "GET /api/v1/roles" do
  ##############################################################################

    #---------------------------------------------------------------------------
    it "returns all user roles ordered by inheritance" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @frank_super_admin.api_access_key
      get "/api/v1/roles"
      last_response.status.should == 200
      result = json_string_to_hash(last_response.body)

      user_roles_json = []
      [
        @user_role_admin,
        @user_role_user,
        @user_role_guest
      ].each do |user_role|
        user_roles_json << {
          :id => user_role.id,
          :description => user_role.description,
          :permissions => user_role.role_permissions.map{|v| v.values } || [] }
      end

      result2 = []
      result.each do |r|
        if r[:id].start_with?("(RSPEC_PREFIX)-")
          result2.push(r)
        end
      end

      result2.should == user_roles_json
    end
    #---------------------------------------------------------------------------
  end


  ##############################################################################
  describe "GET /api/v1/role/:id" do
  ##############################################################################

    #---------------------------------------------------------------------------
    it "returns user role with id and with according permissions" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @frank_super_admin.api_access_key
      get "/api/v1/role/#{@user_role_admin.id}"
      last_response.status.should == 200
      result = json_string_to_hash(last_response.body)

      result.should == {
        :role => @user_role_admin.values,
        :permissions => [@permission1.values]
      }
    end
    #---------------------------------------------------------------------------
  end


  ##############################################################################
  describe "POST /api/v1/role" do
  ##############################################################################

    #---------------------------------------------------------------------------
    it "creates new user role" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @frank_super_admin.api_access_key
      post "/api/v1/role",
        :id => "new_role",
        :inherit_from_id => nil,
        :description => "awesome role"
      last_response.status.should == 201
      result = json_string_to_hash(last_response.body)
      UserRole["new_role"].values.should == result
    end
    #---------------------------------------------------------------------------
  end


  ##############################################################################
  describe "PUT /api/v1/role/:id" do
  ##############################################################################

    #---------------------------------------------------------------------------
    it "updates user role with id" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @frank_super_admin.api_access_key
      put "/api/v1/role/#{@user_role_admin.id}",
        :inherit_from_id => nil,
        :description => "new text"
      last_response.status.should == 200
      result = json_string_to_hash(last_response.body)
      UserRole[@user_role_admin.id].values.should == result
    end
    #---------------------------------------------------------------------------
  end


  ##############################################################################
  describe "DELETE /api/v1/role/:id" do
  ##############################################################################

    #---------------------------------------------------------------------------
    it "deletes user role with id" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @frank_super_admin.api_access_key
      delete "/api/v1/role/#{@user_role_admin.id}"
      last_response.status.should == 200
      UserRole.first(:id => @user_role_admin.id).should eq(nil)
    end
    #---------------------------------------------------------------------------
  end


  ##############################################################################
  describe "GET /api/v1/role/:user_role_id/permission/:role_permission_entitiy" do
  ##############################################################################

    #---------------------------------------------------------------------------
    it "returns role permission with user_role_id and role_permission_entitiy" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @frank_super_admin.api_access_key
      get "/api/v1/role/#{@user_role_admin.id}/permission/#{@permission1.entity}"
      last_response.status.should == 200
      result = json_string_to_hash(last_response.body)
      result.should == @permission1.values
    end
    #---------------------------------------------------------------------------
  end


  ##############################################################################
  describe "PUT /api/v1/role/:user_role_id/permission/:role_permission_entitiy" do
  ##############################################################################

    #---------------------------------------------------------------------------
    it "updates role permission with user_role_id and role_permission_entitiy" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @frank_super_admin.api_access_key
      put "/api/v1/role/#{@user_role_admin.id}/permission/#{@permission1.entity}",
        :permission => "forbid"
      last_response.status.should == 200
      result = json_string_to_hash(last_response.body)
      RolePermission.first(
        :user_role_id => @user_role_admin.id,
        :entity => @permission1.entity).values.should == result
    end
    #---------------------------------------------------------------------------
  end


  ##############################################################################
  describe "DELETE /api/v1/role/:user_role_id/permission/:role_permission_entitiy" do
  ##############################################################################

    #---------------------------------------------------------------------------
    it "deletes role permission with user_role_id and role_permission_entitiy" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @frank_super_admin.api_access_key
      delete "/api/v1/role/#{@user_role_admin.id}/permission/#{@permission1.entity}"
      last_response.status.should == 200
      RolePermission.first(
        :user_role_id => @user_role_admin.id,
        :entity => @permission1.entity).should eq(nil)
    end
    #---------------------------------------------------------------------------
  end


  ##############################################################################
  describe "POST /api/v1/role/:id/permission" do
  ##############################################################################

    #---------------------------------------------------------------------------
    it "create new role permission for user role with id" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @frank_super_admin.api_access_key
      post "/api/v1/role/#{@user_role_admin.id}/permission",
        :entity => "foobar",
        :permission => "allow"
      last_response.status.should == 201
      result = json_string_to_hash(last_response.body)
      RolePermission.first(
        :user_role_id => @user_role_admin.id,
        :entity => "foobar").values.should == result
    end
    #---------------------------------------------------------------------------
  end


end