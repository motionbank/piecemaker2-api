module Piecemaker

  class UserRoles < Grape::API

    #===========================================================================
    resource 'roles' do #=======================================================
    #===========================================================================


      #_________________________________________________________________________
      ##########################################################################
      desc "get all user roles"
      #-------------------------------------------------------------------------
      get "/" do  #/api/v1/roles
      #-------------------------------------------------------------------------
        authorize! :get_roles, User

        # build user roles array
        get_user_roles_ordered_by_inheritance = lambda {
          |id, user_roles_ordered|
            root_user_roles = UserRole.where(:inherit_from_id => id).all
            if root_user_roles
              root_user_roles.each do |user_role|
                user_roles_ordered << user_role
                get_user_roles_ordered_by_inheritance.call(
                  user_role.id, user_roles_ordered)
              end
            end
        }

        @user_roles_ordered = []
        get_user_roles_ordered_by_inheritance.call(nil, @user_roles_ordered)
        
        @user_roles_ordered.reverse!

        user_roles_json = []
        @user_roles_ordered.each do |user_role|
          user_roles_json << {
            :id => user_role.id,
            :description => user_role.description,
            :inherit_from_id => user_role.inherit_from_id,
            :permissions => user_role.role_permissions.map{|v| v.values } || []
          }
        end

        return user_roles_json
      end

    end


    #===========================================================================
    resource 'role' do #=======================================================
    #===========================================================================


      #_________________________________________________________________________
      ##########################################################################
      desc "get user role with according permission"
      #-------------------------------------------------------------------------
      params do
        requires :id, type: String, desc: "id for user role"
      end
      #-------------------------------------------------------------------------
      get "/:id" do  #/api/v1/role/:id
      #-------------------------------------------------------------------------
        authorize! :get_role, User
        @user_role = UserRole.first(:id => params[:id])
        error!('Not found', 404) unless @user_role

        { :permissions => @user_role.role_permissions.map{|v| v.values } || [] 
          }.merge(@user_role)
      end


      #_________________________________________________________________________
      ##########################################################################
      desc "create new user role"
      #-------------------------------------------------------------------------
      params do
        requires :id, type: String, desc: "id for user role (note that id is a string)"
        optional :inherit_from_id, type: String, desc: "inherit permissions from this user role"
        optional :description, type: String, desc: "some additional description"
      end
      #-------------------------------------------------------------------------
      post "/" do  #/api/v1/role
      #-------------------------------------------------------------------------
        authorize! :create_new_role, User
        
        UserRole.unrestrict_primary_key
        @user_role = UserRole.create(
          :id               => params[:id],
          :inherit_from_id  => params[:inherit_from_id],
          :description      => params[:description])
        
        # { :role => @user_role,
        #   :permissions => [] }

        return @user_role
      end


      #_________________________________________________________________________
      ##########################################################################
      desc "update user role"
      #-------------------------------------------------------------------------
      params do
        requires :id, type: String, desc: "id for user role (note that id is a string)"
        optional :inherit_from_id, type: String, desc: "inherit permissions from this user role"
        optional :text, type: String, desc: "some additional description"
      end
      #-------------------------------------------------------------------------
      put "/:id" do  #/api/v1/role/:id
      #-------------------------------------------------------------------------
        authorize! :update_role, User
        @user_role = UserRole.first(:id => params[:id])
        error!('Not found', 404) unless @user_role
        
        @user_role.update_with_params!(params, :inherit_from_id, :text)
        @user_role.save
      end


      #_________________________________________________________________________
      ##########################################################################
      desc "delete user role"
      #-------------------------------------------------------------------------
      params do
        requires :id, type: String, desc: "id for user role (note that id is a string)"
      end
      #-------------------------------------------------------------------------
      delete "/:id" do  #/api/v1/role/:id
      #-------------------------------------------------------------------------
        authorize! :delete_role, User
        @user_role = UserRole.first(:id => params[:id])
        error!('Not found', 404) unless @user_role
        
        @user_role.delete
      end


      #_________________________________________________________________________
      ##########################################################################
      desc "create new role permission for user role with id"
      #-------------------------------------------------------------------------
      params do
        requires :id, type: String, desc: "user_role_id"
        requires :entity, type: String, desc: "name of entity"
        requires :permission, type: String, desc: "allow or forbid"
      end
      #-------------------------------------------------------------------------
      post "/:id/permission" do  #/api/v1/role/:id/permission
      #-------------------------------------------------------------------------
        authorize! :create_new_permission, User
        @user_role = UserRole.first(:id => params[:id])
        error!('Not found', 404) unless @user_role
        
        unless ["allow", "forbid"].include?(params[:permission])
          error!('Bad Request', 400)
        end

        RolePermission.unrestrict_primary_key
        @role_permission = RolePermission.create(
          :user_role_id     => @user_role.id,
          :entity           => params[:entity],
          :permission       => params[:permission])
        
        return @role_permission
      end


      #_________________________________________________________________________
      ##########################################################################
      desc "get role permissions"
      #-------------------------------------------------------------------------
      params do
        requires :user_role_id, type: String, desc: "user role id"
        requires :role_permission_entity, type: String, desc: "permission entity"
      end
      #-------------------------------------------------------------------------
      get "/:user_role_id/permission/:role_permission_entity" do  
        #/api/v1/role/:user_role_id/permission/:role_permission_entity
      #-------------------------------------------------------------------------
        authorize! :get_permission, User
        @role_permission = RolePermission.first(
          :user_role_id => params[:user_role_id],
          :entity => params[:role_permission_entity])
        error!('Not found', 404) unless @role_permission
        return @role_permission
      end


      #_________________________________________________________________________
      ##########################################################################
      desc "update role permissions"
      #-------------------------------------------------------------------------
      params do
        requires :user_role_id, type: String, desc: "user role id"
        requires :role_permission_entity, type: String, desc: "permission entity"
        requires :permission, type: String, desc: "allow or forbid"
      end
      #-------------------------------------------------------------------------
      put "/:user_role_id/permission/:role_permission_entity" do  
        #/api/v1/role/:user_role_id/permission/:role_permission_entity
      #-------------------------------------------------------------------------
        authorize! :update_permission, User
        @role_permission = RolePermission.first(
          :user_role_id => params[:user_role_id],
          :entity => params[:role_permission_entity])
        error!('Not found', 404) unless @role_permission

        unless ["allow", "forbid"].include?(params[:permission])
          error!('Bad Request', 400)
        end

        @role_permission.update_with_params!(params, :permission)
        @role_permission.save
      end


      #_________________________________________________________________________
      ##########################################################################
      desc "delete role permissions"
      #-------------------------------------------------------------------------
      params do
        requires :user_role_id, type: String, desc: "user role id"
        requires :role_permission_entity, type: String, desc: "permission entity"
      end
      #-------------------------------------------------------------------------
      delete "/:user_role_id/permission/:role_permission_entity" do  
        #/api/v1/role/:user_role_id/permission/:role_permission_entity
      #-------------------------------------------------------------------------
        authorize! :delete_permission, User
        @role_permission = RolePermission.first(
          :user_role_id => params[:user_role_id],
          :entity => params[:role_permission_entity])
        error!('Not found', 404) unless @role_permission

        @role_permission.delete
      end
    end



  end
end