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
          :description => user_role.description}
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

end