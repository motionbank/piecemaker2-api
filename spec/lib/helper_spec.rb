require 'spec_helper'

describe "Module helper" do
  
  include Rack::Test::Methods
  def app
    Piecemaker::API
  end

  describe "Module API_Access_key" do
    it "generates an api access key" do
      pending
    end

    it "checks if an api access key makes sense" do
      pending
    end

  end

  describe "Module Password" do
    it "generates a password" do
      pending
    end

  end


  describe "Module Auth" do
    before(:all) do
      truncate_db
      
      # admin inherits from user
      # user inherits  from guest
      # guest inherits nothing

      # entity    admin user guest
      # a         >     >    Y
      # b         >     Y    -
      # c         Y     -    -
      #
      # x         >     >    N
      # y         >     N    -
      # z         N     -    -
      #
      # r         >     N    Y
      # s         N     >    Y
      # t         Y     N    Y
      # u         N     Y    N

      @entity_prefix = "(RSPEC_PREFIX)-"

      factory_batch do 
  
        @user_role_admin          = UserRole.make :admin
        @user_role_user           = UserRole.make :user
        @user_role_guest          = UserRole.make :guest
        

        @user_role_admin_allow_c   = RolePermission.make :allow,
                                      :user_role_id => @user_role_admin.id,
                                      :entity => @entity_prefix + "c"
        @user_role_admin_forbid_z  = RolePermission.make :forbid,
                                      :user_role_id => @user_role_admin.id,
                                      :entity => @entity_prefix + "z"
        @user_role_admin_forbid_s  = RolePermission.make :forbid,
                                      :user_role_id => @user_role_admin.id,
                                      :entity => @entity_prefix + "s"
        @user_role_admin_allow_t   = RolePermission.make :allow,
                                      :user_role_id => @user_role_admin.id,
                                      :entity => @entity_prefix + "t"
        @user_role_admin_forbid_u  = RolePermission.make :forbid,
                                      :user_role_id => @user_role_admin.id,
                                      :entity => @entity_prefix + "u"

        @user_role_admin_invalid_type  = RolePermission.make :invalid_permission_type,
                                      :user_role_id => @user_role_admin.id,
                                      :entity => "this_is_a_invalid_permission_type"



        @user_role_user_allow_b    = RolePermission.make :allow,
                                      :user_role_id => @user_role_user.id,
                                      :entity => @entity_prefix + "b"
        @user_role_user_forbid_y   = RolePermission.make :forbid,
                                      :user_role_id => @user_role_user.id,
                                      :entity => @entity_prefix + "y"
        @user_role_user_forbid_r   = RolePermission.make :forbid,
                                      :user_role_id => @user_role_user.id,
                                      :entity => @entity_prefix + "r"
        @user_role_user_forbid_t   = RolePermission.make :forbid,
                                      :user_role_id => @user_role_user.id,
                                      :entity => @entity_prefix + "t"                                      
        @user_role_user_allow_u    = RolePermission.make :allow,
                                      :user_role_id => @user_role_user.id,
                                      :entity => @entity_prefix + "u"


        @user_role_guest_allow_a    = RolePermission.make :allow,
                                      :user_role_id => @user_role_guest.id,
                                      :entity => @entity_prefix + "a"
        @user_role_guest_forbid_x   = RolePermission.make :forbid,
                                      :user_role_id => @user_role_guest.id,
                                      :entity => @entity_prefix + "x"                
        @user_role_guest_allow_r    = RolePermission.make :allow,
                                      :user_role_id => @user_role_guest.id,
                                      :entity => @entity_prefix + "r"
        @user_role_guest_allow_s    = RolePermission.make :allow,
                                      :user_role_id => @user_role_guest.id,
                                      :entity => @entity_prefix + "s"
        @user_role_guest_allow_t    = RolePermission.make :allow,
                                      :user_role_id => @user_role_guest.id,
                                      :entity => @entity_prefix + "t"                                      
        @user_role_guest_forbid_u   = RolePermission.make :forbid,
                                      :user_role_id => @user_role_guest.id,
                                      :entity => @entity_prefix + "u"


        @pan                      = User.make :pan
        @peter                    = User.make :peter
        @hans_admin               = User.make :hans_admin
        @klaus_disabled           = User.make :klaus_disabled
        @user_with_no_api_access_key = User.make :user_with_no_api_access_key

        @event_group              = EventGroup.make :alpha

        @user_has_event_group     = UserHasEventGroup.make :default,
                                      :user_id => @pan.id,
                                      :event_group_id => @event_group.id,
                                      :user_role_id => @user_role_admin.id

        @event                    = Event.make :big, 
                                      :event_group_id => @event_group.id,
                                      :created_by_user_id => @pan.id
        
        @event_field              = EventField.make :flag1,
                                      :event_id => @event.id       

      end
    end


    describe "get_permission_recursively" do
      it "returns permission for role that inherits" do
        permission = Piecemaker::Helper::Auth::get_permission_recursively(
          @user_role_admin, @entity_prefix + "a")
        permission.should == @user_role_guest_allow_a
      end

      it "returns permission for role that does not inherit" do
        permission = Piecemaker::Helper::Auth::get_permission_recursively(
          @user_role_admin, @entity_prefix + "c")
        permission.should == @user_role_admin_allow_c
      end

      it "returns no permission when no permission exists" do
        permission = Piecemaker::Helper::Auth::get_permission_recursively(
          @user_role_user, @entity_prefix + "c")
        permission.should eq(nil)      
      end
    end

    describe "get_user_by_api_acccess_key" do
      it "returns enabled user by api access key" do
        user = Piecemaker::Helper::Auth::get_user_by_api_acccess_key(
          @pan.api_access_key)
        user.should == @pan
      end

      it "does not return disabled users" do
        user = Piecemaker::Helper::Auth::get_user_by_api_acccess_key(
          @klaus_disabled.api_access_key)
        user.should == nil
      end

      it "returns nil if api access key is nil" do
        user = Piecemaker::Helper::Auth::get_user_by_api_acccess_key(
          nil)
        user.should == nil
      end

      it "returns nil if no api access key is found" do
        user = Piecemaker::Helper::Auth::get_user_by_api_acccess_key(
          @user_with_no_api_access_key.api_access_key)
        user.should == nil
      end
    end


    describe "get_user_role_from_model" do
      it "returns user_role for UserHasEventGroup" do
        user_role_id = Piecemaker::Helper::Auth::get_user_role_from_model(
          @user_has_event_group, @pan)
        user_role_id.should == @user_role_admin.id
      end

      it "returns user_role for EventGroup" do
        user_role_id = Piecemaker::Helper::Auth::get_user_role_from_model(
          @event_group, @pan)
        user_role_id.should == @user_role_admin.id
      end

      it "fails when trying to return user_role for EventGroup " +
         "with wrong user" do
        user_role_id = Piecemaker::Helper::Auth::get_user_role_from_model(
          @event_group, @peter)
          user_role_id.should eq(nil)
      end

      it "returns user_role for Event" do
        user_role_id = Piecemaker::Helper::Auth::get_user_role_from_model(
          @event, @pan)
        user_role_id.should == @user_role_admin.id
      end

      it "fails when trying to return user_role for Event " +
         "with wrong user" do
        user_role_id = Piecemaker::Helper::Auth::get_user_role_from_model(
          @event, @peter)
          user_role_id.should eq(nil)
      end

      it "returns user_role for EventField" do
        user_role_id = Piecemaker::Helper::Auth::get_user_role_from_model(
          @event_field, @pan)
        user_role_id.should == @user_role_admin.id
      end

      it "fails when trying to return user_role for EventField " +
         "with wrong user" do
        user_role_id = Piecemaker::Helper::Auth::get_user_role_from_model(
          @event_field, @peter)
          user_role_id.should eq(nil)
      end

      it "returns user_role for UserRole" do
        user_role_id = Piecemaker::Helper::Auth::get_user_role_from_model(
          @user_role_admin, @pan)
        user_role_id.should == @user_role_admin.id
      end

      it "returns user_role for RolePermission" do
        user_role_id = Piecemaker::Helper::Auth::get_user_role_from_model(
          @user_role_admin_allow_c, @pan)
        user_role_id.should == @user_role_admin.id
      end

      it "throws error if no valid model is passed" do
        expect {
          user_role_id = Piecemaker::Helper::Auth::get_user_role_from_model(
            @pan)          
          }.to raise_error
      end

    end


    describe "authorize!" do
      
      before(:all) do
        # create dummy routes to test against ...

        app.get "/rspec_dummy_route_for_authorize_plain" do
          authorize!
        end

        app.get "/rspec_dummy_route_for_authorize_super_admin_only" do
          authorize! :super_admin_only
        end

        app.get "/rspec_dummy_route_for_authorize_permission" +
                "/:permission/:user_id/:event_group_id" do
          @user_has_event_group = UserHasEventGroup.first(
            :user_id => params[:user_id],
            :event_group_id => params[:event_group_id])
          error!('Invalid :user_id, :event_group_id combination', 500) unless @user_has_event_group
          authorize! params[:permission], @user_has_event_group 
        end
      end

      it "fails when no or empty api access key is sent" do
        get "/api/v1/rspec_dummy_route_for_authorize_plain" 
        last_response.status.should == 400
        
        header "X-Access-Key", nil
        get "/api/v1/rspec_dummy_route_for_authorize_plain" 
        last_response.status.should == 400
      end

      it "fails for invalid api access key" do
        header "X-Access-Key", "i am an invalid api access key!!"
        get "/api/v1/rspec_dummy_route_for_authorize_plain" 
        last_response.status.should == 401
      end

      it "returns user if i am a super admin" do
        header "X-Access-Key", @hans_admin.api_access_key
        get "/api/v1/rspec_dummy_route_for_authorize_plain" 
        last_response.status.should == 200

        results = json_string_to_hash(last_response.body)
        results.should == @hans_admin.values
      end

      it "returns user if super admin is needed and super admin given" do
        header "X-Access-Key", @hans_admin.api_access_key
        get "/api/v1/rspec_dummy_route_for_authorize_super_admin_only" 
        last_response.status.should == 200

        results = json_string_to_hash(last_response.body)
        results.should == @hans_admin.values
      end

      it "fails if super admin is needed, but no super admin given" do
        header "X-Access-Key", @peter.api_access_key
        get "/api/v1/rspec_dummy_route_for_authorize_super_admin_only" 
        last_response.status.should == 403
      end


      # verify permissions ...

      it "only gets user roles for the currently logged in user" do
        # sending @peters access key (logged in user)
        # trying to get @pans user role assignment (@user_has_event_group)
        header "X-Access-Key", @peter.api_access_key
        get "/api/v1/rspec_dummy_route_for_authorize_permission" +
            "/a" +
            "/#{@user_has_event_group.user_id}" + 
            "/#{@user_has_event_group.event_group_id}" 
        last_response.status.should == 403
      end

      it "raises error if permission type is not allow or forbid", :focus do
        header "X-Access-Key", @pan.api_access_key
        get "/api/v1/rspec_dummy_route_for_authorize_permission" +
            "/this_is_a_invalid_permission_type" +
            "/#{@user_has_event_group.user_id}" + 
            "/#{@user_has_event_group.event_group_id}" 
        last_response.status.should == 500
      end




    end
  end
end

