require 'spec_helper'

describe "Module helper" do

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

    describe "get_permission_recursively" do
      before(:each) do
        truncate_db
        
        factory_batch do 



        end

        it "returns permission for role that inherits" do
          pending
        end

        it "returns permission for role that does not inherit" do
          pending
        end

        it "returns no permission when no permission exists" do
          pending
        end

      end
    end

    describe "authorize!" do
      before(:each) do
        truncate_db
        
        # entity    guest user admin
        # a         Y     >    >
        # b         -     Y    >
        # c         -     -    Y
        # x         Y     N    >
        # y         N     Y    >
        # z         Y     >    N

        
        # factory_batch do 



        #   entity_prefix = "__some_random_SURY24259_chars_"
        #   @user_role_guest          = UserRole.make :guest
        #   @user_role_user           = UserRole.make :user
        #   @user_role_admin          = UserRole.make :admin
          

        #   UserRole.make_set :role_permission_matrix
          
        #   @user_role_guest_allow_a  = RolePermission.make :allow,
        #                                 :user_role_id => @user_role_guest.id,
        #                                 :entity => entity_prefix + "a"

        #   @user_role_guest_allow_b  = RolePermission.make :allow,
        #                                 :user_role_id => @user_role_guest.id,
        #                                 :entity => entity_prefix + "b"

        #   @user_role_guest_allow_c  = RolePermission.make :allow,
        #                                 :user_role_id => @user_role_guest.id,
        #                                 :entity => entity_prefix + "c"                                  



        #   @user_allow_read_item     = RolePermission.make :allow,
        #                                 :user_role_id => @user_role_user.id,
        #                                 :entity => "_awesome_item_xyz"

        #   @user_forbid_delete_item  = RolePermission.make :forbid,
        #                                 :user_role_id => @user_role_user.id,
        #                                 :entity => "_awesome_item_xyz"


        #   @admin_allow_read_item    = RolePermission.make :allow,
        #                                 :user_role_id => @user_role_admin.id,
        #                                 :entity => "_awesome_item_xyz"

        #   @admin_allow_read_another_item = RolePermission.make :allow,
        #                                     :user_role_id => @user_role_admin.id,
        #                                     :entity => "_another_awesome_item_xyz"
            

        #   @pan                      = User.make :pan

        #   @event_group              = EventGroup.make :alpha

        #   @user_has_event_group     = UserHasEventGroup.make :default,
        #                                 :user_id => @pan.id,
        #                                 :event_group_id => @event_group.id,
        #                                 :user_role_id => @user_role_admin.id
        # end

      end

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

