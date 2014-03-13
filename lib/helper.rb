module Sequel
  class Model
    def update_with_params!(params, *attributes)
      attributes.each do |key, value|
        if params.include?(key)
          self[key] = params[key]
        end
      end
    end

  end
end


module Sequel
  module Plugins
    module Paginate2
      module ClassMethods

        # example calls
        # 
        # User.page(params).where(:name => "peter")
        # User.page({:count => 100, :max_id => 123, :since_id => 999})
        # User.page(params, :user_id_pk) # no composite keys supported!
        def page(params, primary_key=nil)
          new_dataset = self.dataset

          count = params[:count] || 1
          new_dataset = new_dataset.limit(count)

          if primary_key
            # primary_key = primary_key
          else
            primary_key = self.primary_key()
            if primary_key.is_a?(Array)
              raise RuntimeError, 'Composite keys not supported for paging.'
            end
          end

          new_dataset = new_dataset.where("#{primary_key.to_s} <= #{params[:max_id].to_i}") if(params[:max_id])
          new_dataset = new_dataset.where("#{primary_key.to_s} > #{params[:since_id].to_i}") if(params[:since_id])

          # puts new_dataset.sql # for debug
          return new_dataset
        end
      end
    end
  end
end
Sequel::Model.plugin Sequel::Plugins::Paginate2




module Piecemaker
  # consider context of execution ...
  # included with 'helpers Piecemaker::Helper::Auth' in api
  # http://intridea.github.io/grape/docs/index.html#Helpers
  module Helper


    module Token
      # example calls ...
      #
      # verify_token! @event
      # verify_token! @event, params[:token]
      #
      # return new token string on success
      # raise and exit on error
      def verify_token!(*args)
        token_length = 10

        @model = args[0]

        unless @model.keys.include? :token
          $logger.error("Missing token in @model.")
          error!('Internal Server Error', 500)
        end

        # unless @model.token return true, because there is nothing to compare
        # this is usually the case, when a new record is created
        if @model.token == "" || @model.token.nil?
          @model.token = Piecemaker::Helper::Password::generate(token_length)
          return true
        end

        if args[1]
          token = args[1]
        elsif params[:token]
          token = params[:token]
        else
          $logger.error("No token given.")
          error!('Internal Server Error', 500)
        end
        
        # compare tokens
        if @model.token == token
          @model.token = Piecemaker::Helper::Password::generate(token_length)
          return true
        else
          error!('Conflict', 409)
        end
      end
    end


    module Auth
      # example calls ...
      # 
      # authorize! # just logged in user
      # authorize! :list_all, User # or other Model
      #
      # authorize! :get_events, @user_has_event_group, 
      # authorize! :get_events, @event_group
      # authorize! :get_events, @event
      # authorize! :get_events, @event_field
      def authorize!(*args)
        api_access_key = headers['X-Access-Key'] || nil
        if api_access_key

          # check if api_access_key is valid and the user is not disabled
          @user = Piecemaker::Helper::Auth::get_user_by_api_acccess_key(api_access_key)
          error!('Unauthorized', 401) unless @user
                   
          # only logged in user is required ...
          return @user if args.count == 0

          # verify permissions ...
          entity = args[0]
          if(args[1].is_a? Class)
            _class = args[1]
            if _class.name == "User"
              @model = @user
            else
              error!('Internal Server Error', 500)
            end
          else
            @model = args[1]
          end

          # debug
          # puts @model.inspect
          # puts @user.inspect

          # yo, whats up. i am a super admin!
          return @user if @user.user_role_id == "super_admin"
            
          user_role_id = Piecemaker::Helper::Auth::\
            get_user_role_from_model(@model, @user) 
          error!('Forbidden', 403) unless user_role_id

          @role_permission = Piecemaker::Helper::Auth::\
            get_permission_recursively(user_role_id, entity)

          # debug
          # puts @role_permission.inspect
          # puts user_role_id
          # puts entity
          # puts @model.inspect

          error!('Forbidden', 403) unless @role_permission

          if @role_permission.permission == "allow"
            # okay, come in!
            return @user
          elsif @role_permission.permission == "forbid"
            error!('Forbidden', 403)
          else
            $logger.error("Unknown permission value: '#{@role_permission.permission}'")
            error!('Internal Server Error', 500)
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

        elsif model.is_a? User
          return model.user_role_id

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
        # $logger.debug("#{entity} - #{user_role_id}")

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
        return false unless api_access_key
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
