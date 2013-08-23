module Piecemaker
  module Helper


    module Auth
      # consider context of execution ...
      # included with 'helpers Piecemaker::Helper::Auth' in api
      # http://intridea.github.io/grape/docs/index.html#Helpers
      # 
      # example calls ...
      # 
      # authorize! :super_admin_only
      #
      # authorize! :get_events, @user_has_event_group, 
      # authorize! :get_events, @event_group
      # authorize! :get_events, @event
      # authorize! :get_events, @event_field
      def authorize!(*args)
        api_access_key = headers['X-Access-Key'] || nil
        if api_access_key
          # check if api_access_key is valid and the user is not disabled
          @user = Piecemaker::Helper::Auth::get_user_by_api_acccess_key(
            api_access_key)
          unless @user
            error!('Unauthorized', 401)
          else
            # if you are a super admin, dont check any further ...
            if @user.is_super_admin
              return @user
            end 

            # is this method for super users only?
            if args.include?(:super_admin_only) && !@user.is_super_admin
              error!('Forbidden', 403)
            end

            args.delete :super_admin_only
            if args.count == 0
              # only check if user is logged in
              # and since we got here, he is
              return @user
            else
              # verify permissions ...
              entity = args[0]
              @model = args[1]

              user_role_id = Piecemaker::Helper::Auth::\
                get_user_role_from_model(@model, @user)
              error!('Forbidden', 403) unless user_role_id

              @role_permission = Piecemaker::Helper::Auth::\
                get_permission_recursively(user_role_id, entity)
              if @role_permission.permission == "allow"
                # okay, come in!
                return @user
              elsif @role_permission.permission == "forbid"
                error!('Forbidden', 403)
              else
                raise TypeError, "Unknown permission value"
              end

            end
          end
        else
          error!('Bad Request, Missing X-Access-Key in Headers', 400)
        end
      end


      def self.get_user_by_api_acccess_key(api_access_key)
        return nil unless api_access_key
        User.first(
          :api_access_key => api_access_key,
          :is_disabled => false)
      end

      def self.get_user_role_from_model(model, user)
        if model.is_a? UserHasEventGroup
          return nil if user.id != model.user_id
          return model.user_role_id

        elsif model.is_a? EventGroup
          @_user_has_event_group = UserHasEventGroup.first(
            :user_id => user.id, 
            :event_group_id => model.id)
          return nil unless @_user_has_event_group
          return @_user_has_event_group.user_role_id

        elsif model.is_a? Event
          @_user_has_event_group = UserHasEventGroup.first(
            :user_id => user.id,
            :event_group_id => model.event_group_id)
          return nil unless @_user_has_event_group
          return @_user_has_event_group.user_role_id

        elsif model.is_a? EventField
          @_event = Event.first(:id => model.event_id)
          return nil unless @_event

          @_user_has_event_group = UserHasEventGroup.first(
            :user_id => user.id,
            :event_group_id => @_event.event_group_id)
          return nil unless @_user_has_event_group
          return @_user_has_event_group.user_role_id

        else
          raise ArgumentError, 
            "Expected valid model as first argument"
        end
      end

      def self.get_permission_recursively(user_role, entity)
        entity = entity.to_s

        if user_role.is_a? UserRole
          user_role_id = user_role.id
        else
          user_role_id = user_role
        end

        # for debugging:
        # puts "#{entity} - #{user_role_id}"

        # permission defined for this role?
        @role_permission = RolePermission.first(
          :user_role_id => user_role_id, :entity => entity)

        if @role_permission
          # yes, return it
          return @role_permission
        else
          # no, look for parent user role
          @user_role = UserRole.first(:id => user_role_id)
          if @user_role.inherit_from_id
            # check, if permission is defined for parent role ...
            return self.get_permission_recursively(
              @user_role.inherit_from_id, entity)
          else
            # wasnt able to find permission
            return nil
          end
        end
      end

    end



    module API_Access_Key
      API_ACCESS_KEY_LENGTH = 16

      def self.generate
        chars = [('a'..'z'),('A'..'Z'),(0..9)].map{|i| i.to_a}.flatten
        api_access_key = (0...API_ACCESS_KEY_LENGTH-5).map{ 
          chars[rand(chars.length)] }.join
        api_access_key = "0310X#{api_access_key}"
      end

      def self.makes_sense?(api_access_key)
        api_access_key.length === API_ACCESS_KEY_LENGTH &&
          api_access_key.start_with?("0310X") ? true : false
      end
    end


    module Password
      def self.generate(length)
        chars = [('a'..'z'),('A'..'Z'),(0..9)].map{|i| i.to_a}.flatten
        (0...length).map{ chars[rand(chars.length)] }.join
      end
    end

  end
end
