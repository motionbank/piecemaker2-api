require 'spec_helper'

describe "Module helper" do
  
  include Rack::Test::Methods
  def app
    Piecemaker::API
  end
  


  describe "Module API_Access_key" do
    it "generates an api access key" do
      key = Piecemaker::Helper::API_Access_Key::generate
      key.should_not eq(nil)

      key.length.should == Piecemaker::Helper::API_Access_Key::\
        API_ACCESS_KEY_LENGTH
    end

    it "checks if an api access key makes sense" do
      key = Piecemaker::Helper::API_Access_Key::generate
      result = Piecemaker::Helper::API_Access_Key::makes_sense? key
      result.should == true
    end

    it "fails, if an api access key makes no sense" do
      key = "aaaaaaaaaaaaaaaa"
      result = Piecemaker::Helper::API_Access_Key::makes_sense? key
      result.should == false
    end

    it "fails, if an api access key is empty" do
      result = Piecemaker::Helper::API_Access_Key::makes_sense? nil
      result.should == false

      result = Piecemaker::Helper::API_Access_Key::makes_sense? ""
      result.should == false
    end

  end

  describe "Module Password" do
    it "generates a password" do
      pw = Piecemaker::Helper::Password::generate(6)
      pw.should_not eq(nil)
      pw.should_not eq("")
      pw.length.should == 6
    end

  end


  describe "Module Auth" do
    before(:all) do
      truncate_db
      
      # admin inherits from user
      # user inherits  from guest
      # guest inherits nothing

      # Permission Matrix
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

        @user_has_event_group      = UserHasEventGroup.make :default,
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

      it "throws error if no valid model is passed" do
        expect {
          user_role_id = Piecemaker::Helper::Auth::get_user_role_from_model(
            @pan)          
          }.to raise_error
      end

    end


    # create dummy routes to test against ...
    Piecemaker::API.get "/rspec_dummy_route_for_authorize_plain" do
      authorize!
    end

    Piecemaker::API.get "/rspec_dummy_route_for_authorize_super_admin_only" do
      authorize! :super_admin_only
    end

    Piecemaker::API.get "/rspec_dummy_route_for_authorize_permission" +
            "/:permission/:user_id/:event_group_id" do
      @user_has_event_group = UserHasEventGroup.first(
        :user_id => params[:user_id],
        :event_group_id => params[:event_group_id])
      error!('Invalid :user_id, :event_group_id combination', 500) unless @user_has_event_group
      authorize! params[:permission], @user_has_event_group 
    end


    describe "authorize!" do
      
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

      it "raises error if permission type is not allow or forbid" do
        header "X-Access-Key", @pan.api_access_key
        get "/api/v1/rspec_dummy_route_for_authorize_permission" +
            "/this_is_a_invalid_permission_type" +
            "/#{@user_has_event_group.user_id}" + 
            "/#{@user_has_event_group.event_group_id}" 
        last_response.status.should == 500
      end

      # verify permissions matrix ...
      describe "Permission Matrix"  do

        describe "entity    admin user guest" do

          before(:each) do
            truncate_table :user_has_event_groups
          end

          def test_permission(permission, entity, user, role)
            # assign role to user via user_has_event_group
            user_has_event_group = nil
            factory_batch do 
              user_has_event_group = UserHasEventGroup.make :default,
                :user_id => user.id,
                :user_role_id => role.id,
                :event_group_id => @event_group.id
            end
            
            # send request to dummy authorize route  
            header "X-Access-Key", user.api_access_key
            get "/api/v1/rspec_dummy_route_for_authorize_permission" +
                "/#{@entity_prefix}" + entity +
                "/#{user_has_event_group.user_id}" + 
                "/#{user_has_event_group.event_group_id}" 

            # check permission
            if permission == "allow"
              last_response.status.should == 200
              json_string_to_hash(last_response.body).should == user.values
            elsif permission == "forbid"
              last_response.status.should == 403
            end
          end

          # entity a
          it "a         >     >    Y  (as guest)" do
            test_permission("allow", "a", @pan, @user_role_guest)
          end
          it "a         >     >    Y  (as user)" do
            test_permission("allow", "a", @pan, @user_role_user)
          end
          it "a         >     >    Y  (as admin)" do
            test_permission("allow", "a", @pan, @user_role_admin)
          end

          # entity b
          it "b         >     Y    -  (as guest)" do
            test_permission("forbid", "b", @pan, @user_role_guest)
          end
          it "b         >     Y    -  (as user)" do
            test_permission("allow", "b", @pan, @user_role_user)
          end
          it "b         >     Y    -  (as admin)" do
            test_permission("allow", "b", @pan, @user_role_admin)
          end

          # entity c
          it "c         Y     -    -  (as guest)" do
            test_permission("forbid", "c", @pan, @user_role_guest)
          end
          it "c         Y     -    -  (as user)" do
            test_permission("forbid", "c", @pan, @user_role_user)
          end
          it "c         Y     -    -  (as admin)" do
            test_permission("allow", "c", @pan, @user_role_admin)
          end
        

          # entity x
          it "x         >     >    N  (as guest)" do
            test_permission("forbid", "x", @pan, @user_role_guest)
          end
          it "x         >     >    N  (as user)" do
            test_permission("forbid", "x", @pan, @user_role_user)
          end
          it "x         >     >    N  (as admin)" do
            test_permission("forbid", "x", @pan, @user_role_admin)
          end    

          # entity y
          it "y         >     N    -  (as guest)" do
            test_permission("forbid", "y", @pan, @user_role_guest)
          end
          it "y         >     N    -  (as user)" do
            test_permission("forbid", "y", @pan, @user_role_user)
          end
          it "y         >     N    -  (as admin)" do
            test_permission("forbid", "y", @pan, @user_role_admin)
          end      

          # entity z
          it "z         N     -    -  (as guest)" do
            test_permission("forbid", "z", @pan, @user_role_guest)
          end
          it "z         N     -    -  (as user)" do
            test_permission("forbid", "z", @pan, @user_role_user)
          end
          it "z         N     -    -  (as admin)" do
            test_permission("forbid", "z", @pan, @user_role_admin)
          end  

          # entity r
          it "r         >     N    Y  (as guest)" do
            test_permission("allow", "r", @pan, @user_role_guest)
          end
          it "r         >     N    Y  (as user)" do
            test_permission("forbid", "r", @pan, @user_role_user)
          end
          it "r         >     N    Y  (as admin)" do
            test_permission("forbid", "r", @pan, @user_role_admin)
          end  

          # entity s
          it "s         N     >    Y  (as guest)" do
            test_permission("allow", "s", @pan, @user_role_guest)
          end
          it "s         N     >    Y  (as user)" do
            test_permission("allow", "s", @pan, @user_role_user)
          end
          it "s         N     >    Y  (as admin)" do
            test_permission("forbid", "s", @pan, @user_role_admin)
          end  

          # entity t
          it "t         Y     N    Y  (as guest)" do
            test_permission("allow", "t", @pan, @user_role_guest)
          end
          it "t         Y     N    Y  (as user)" do
            test_permission("forbid", "t", @pan, @user_role_user)
          end
          it "t         Y     N    Y  (as admin)" do
            test_permission("allow", "t", @pan, @user_role_admin)
          end 

          # entity u
          it "u         N     Y    N  (as guest)" do
            test_permission("forbid", "u", @pan, @user_role_guest)
          end
          it "u         N     Y    N  (as user)" do
            test_permission("allow", "u", @pan, @user_role_user)
          end
          it "u         N     Y    N  (as admin)" do
            test_permission("forbid", "u", @pan, @user_role_admin)
          end 

        
        end
      end


    end
  end
end

