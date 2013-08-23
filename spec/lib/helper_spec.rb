require 'spec_helper'

describe "Module helper" do
  
#   subject { Class.new(Grape::API) }
  # def app; subject end

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
        @peter                      = User.make :peter

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

    # binding.pry

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

    describe "get_user_role_from_model", :focus do

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
      
      it "checks if api access key is present" do
        pending
      end

      it "checks if api access key matches user records and user is not disabled" do
        pending
      end

      it "passes for valid super admins when :super_admin_only" do
        pending
      end

      it "fails for non super admins when :super_admin_only" do
        pending
      end

      it "raises error if arguments number is not correct" do
        pending
      end

      it "handles UserHasEventGroup as @model" do
        pending
      end

      it "handles EventGroup as @model" do
        pending
      end

      it "handles Event as @model" do
        pending
      end

      it "handles EventField as @model" do
        pending
      end

      it "handles UserRole as @model" do
        pending
      end

      it "handles RolePermission as @model" do
        pending
      end

      it "raises error if @model cannot be handled" do
        pending
      end

      it "raises error if permission type is not allow or forbid" do
        pending
      end
    end
  end
end

