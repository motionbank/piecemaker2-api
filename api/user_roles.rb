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
            :description => user_role.description
          }
        end

        return user_roles_json
      end

    end

  end
end