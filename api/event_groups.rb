module Piecemaker

  class EventGroups < Grape::API

    #===========================================================================
    resource 'groups' do #======================================================
    #===========================================================================


      #_________________________________________________________________________
      ##########################################################################
      desc "returns all event_groups for currently logged in user"
      #-------------------------------------------------------------------------
      get "/" do  #/api/v1/groups
      #-------------------------------------------------------------------------
        @_user = authorize!
        @_user.event_groups
      end
    end


    #===========================================================================
    resource 'group' do #=======================================================
    #===========================================================================
      

      #_________________________________________________________________________
      ##########################################################################
      desc "creates and returns new event and event_fields" +
           " (requires create_new_event permission)"
      #-------------------------------------------------------------------------
      params do
        requires :id, type: Integer, desc: "event group id"
        requires :utc_timestamp, type: Float, desc: "utc timestamp"
        requires :type, type: String, desc: "type of event"
        optional :duration, type: Float, desc: "duration"
        optional :fields, type: Hash, desc: "optional fields to create for this event"
      end 
      #-------------------------------------------------------------------------
      post "/:id/event" do  #/api/v1/group/:id/event
      #-------------------------------------------------------------------------
        @event_group = EventGroup.first(
          :id => params[:id]) || error!('Not found', 404)

        @_user = authorize! :create_new_event, @event_group

        @event = Event.create(
          :event_group_id     => @event_group.id,
          :created_by_user_id => @_user.id,
          :type               => params[:type],
          :utc_timestamp      => params[:utc_timestamp],
          :duration           => params[:duration])

        # create event fields
        fields = []
        if params[:fields]

          EventField.unrestrict_primary_key
          params[:fields].each do |id, value|
            error!('400 Bad Syntax', 400) if id.length > 32
            fields << EventField.create(
              :event_id => @event.id,
              :id       => id,
              :value    => value)
          end
        end
        
        { :event => @event, 
          :fields => fields }
      end
      

      #_________________________________________________________________________
      ##########################################################################
      desc "create new event_group (together with user_has_event_groups record)" +
           " (:super_admin_only)"
      #-------------------------------------------------------------------------
      params do
        requires :title, type: String, desc: "name of the group"
        requires :text, type: String, desc: "some additional description"
          # @todo type: Text not String
      end 
      #-------------------------------------------------------------------------
      post "/" do  #/api/v1/group
      #-------------------------------------------------------------------------
        @_user = authorize!
        
        @event_group = EventGroup.create(
          :created_by_user_id => @_user.id,
          :title              => params[:title],
          :text               => params[:text])

        UserHasEventGroup.unrestrict_primary_key
        UserHasEventGroup.create(
          :user_id => @_user.id,
          :event_group_id => @event_group.id,
          :user_role_id => "group_admin")

        return @event_group
      end
      

      #_________________________________________________________________________
      ##########################################################################
      desc "returns event_group with id" + 
          " (requires get_event_group permission)"
      #-------------------------------------------------------------------------
      params do
        requires :id, type: Integer, desc: "event group id"
      end
      #-------------------------------------------------------------------------
      get "/:id" do  #/api/v1/group/:id
      #-------------------------------------------------------------------------
        @event_group = EventGroup.first(:id => params[:id]) 
        error!('Not found', 404) unless @event_group

        authorize! :get_event_group, @event_group
        @event_group 
      end
      

      #_________________________________________________________________________
      ##########################################################################
      desc "updates event_group with id" + 
           " (requires update_event_group permission)"
      #-------------------------------------------------------------------------
      params do
        requires :id, type: Integer, desc: "event group id"
        optional :title, type: String, desc: "name of the group"
        optional :text, type: String, desc: "some additional description"
      end
      #-------------------------------------------------------------------------
      put "/:id" do  #/api/v1/group/:id
      #-------------------------------------------------------------------------
        @event_group = EventGroup.first(:id => params[:id])
        error!('Not found', 404) unless @event_group

        authorize! :update_event_group, @event_group

        @event_group.update_with_params!(params, :title, :text)
        @event_group.save
      end
      

      #_________________________________________________________________________
      ##########################################################################
      desc "deletes event_group with id" + 
           " (requires delete_event_group permission)"
      #-------------------------------------------------------------------------
      params do
        requires :id, type: Integer, desc: "event_group id"
      end
      #-------------------------------------------------------------------------
      delete "/:id" do #/api/v1/group/:id
      #-------------------------------------------------------------------------
        @event_group = EventGroup.first(:id => params[:id])
        error!('Not found', 404) unless @event_group

        authorize! :delete_event_group, @event_group

        @event_group.delete
      end
       

      #_________________________________________________________________________
      ##########################################################################
      desc "returns all events (filter options are connect with AND)" + 
           " (requires get_events permission)"
      #-------------------------------------------------------------------------
      params do
        requires :id, type: Integer, desc: "event group id"
        optional :from, type: Float, desc: ">= utc_timestamp"
        optional :to, type: Float, desc: "<= utc_timestamp"
        optional :type, type: String, desc: "event type "
        optional :fields, type: Hash, desc: "filter by event field key"
        optional :count_only, type: Boolean, desc: "return count of events only"
      end
      #-------------------------------------------------------------------------
      get "/:id/events" do  #/api/v1/group/:id/events
      #-------------------------------------------------------------------------
        @event_group = EventGroup.first(:id => params[:id])
        error!('Not found', 404) unless @event_group

        authorize! :get_events, @event_group 

        # @todo: paging

        where = [{:event_group_id => @event_group.id}]

        where << {:type => params[:type]} if params[:type]
        where << ['utc_timestamp >= ?', params[:from]] if params[:from]
        where << ['utc_timestamp <= ?', params[:to]] if params[:to]

        # load event
        @events = Event.where( where )

        # load all event fields (for all events) in one query
        @event_fields = EventField
          .where(:event_id => @events.map{|event| event.id})
          .to_hash_groups(:event_id, nil)
        
        @return_events = []
        if params[:fields]
          # futher field conditions to check ...
          @events.each do |event|

            # verify that field conditions apply ...
            counter = 0
            params[:fields].each do |id, value|
              if @event_fields[event.id]
                @event_fields[event.id].each do |event_field|
                  if event_field.id == id && event_field.value == value
                    counter += 1
                  end
                end
              end
            end

            # if all conditions are true, return this event 
            # (with its event fields)
            if counter == params[:fields].length
              @return_events << { 
                :event => event, 
                :fields => @event_fields[event.id] || [] }
            end
          end

        else
          # no further field conditions ...
          @events.each do |event|
            @return_events << { 
              :event => event, 
              :fields => @event_fields[event.id] || [] }
          end
        end

        # free memory
        @events, @event_fields = nil

        if params[:count_only]
          return {"count" => @return_events.count}
        else
          return @return_events
        end
      end
      

      #_________________________________________________________________________
      ##########################################################################
      desc "returns all users for event_group with id"
      #-------------------------------------------------------------------------
      params do
        requires :id, type: Integer, desc: "event group id"
      end
      #-------------------------------------------------------------------------
      get "/:id/users" do  #/api/v1/group/:id/users
      #-------------------------------------------------------------------------
        @event_group = EventGroup.first(:id => params[:id])
        error!('Not found', 404) unless @event_group

        authorize! :get_users_for_event_group, @event_group

        @event_group.users
      end


      #_________________________________________________________________________
      ##########################################################################
      desc "adds a user to an event_group"
      #-------------------------------------------------------------------------
      params do
        requires :event_group_id, type: Integer, desc: "event_group id"
        requires :user_id, type: Integer, desc: "user id"
        optional :user_role_id, type: String, desc: "user role"
      end
      #-------------------------------------------------------------------------
      post "/:event_group_id/user/:user_id" do 
        #/api/v1/group/:event_group_id/user/:user_id
      #-------------------------------------------------------------------------
        @event_group = EventGroup.first(:id => params[:event_group_id])
        error!('Event Group not found', 404) unless @event_group

        authorize! :add_user_to_event_group, @event_group

        @user = User.first(:id => params[:user_id])
        error!('User not found', 404) unless @user
        
        if params[:user_role_id]
          @user_role = UserRole.first(:id => params[:user_role_id])
          error!('Invalid user role', 404) unless @user_role
        else
          params[:user_role_id] = nil # make sure its nil
        end

        UserHasEventGroup.unrestrict_primary_key
        UserHasEventGroup.create(
          :user_id => params[:user_id],
          :event_group_id => params[:event_group_id],
          :user_role_id => params[:user_role_id])

        {:status => true}
      end


      #_________________________________________________________________________
      ##########################################################################
      desc "updates attributes for user <-> event_group relation"
      #-------------------------------------------------------------------------
      params do
        requires :event_group_id, type: Integer, desc: "event_group id"
        requires :user_id, type: Integer, desc: "user id"
        optional :user_role_id, type: String, desc: "user role"
      end
      #-------------------------------------------------------------------------
      put "/:event_group_id/user/:user_id" do 
        #/api/v1/group/:event_group_id/user/:user_id
      #-------------------------------------------------------------------------
        @event_group = EventGroup.first(:id => params[:event_group_id])
        error!('Event Group not found', 404) unless @event_group

        authorize! :update_users_attributes_for_event_group, @event_group

        @user_has_event_group = UserHasEventGroup.first(
          :user_id => params[:user_id],
          :event_group_id => params[:event_group_id])
        error!('Relation not found', 404) unless @user_has_event_group
        
        # check if there is at least one guy with "group_admin" 
        # role in the event group
        if params[:user_role_id] && params[:user_role_id] != "group_admin"
          group_admins_count = UserHasEventGroup.where(
            :event_group_id => params[:event_group_id],
            :user_role_id => "group_admin").count
          unless group_admins_count >= 1
            error!('Every event group needs at least one group admin', 409) 
          end
        end

        @user_has_event_group.update_with_params!(params, :user_role_id)
        @user_has_event_group.save
      end


      #_________________________________________________________________________
      ##########################################################################
      desc "deletes a user from an event_group"
      #-------------------------------------------------------------------------
      params do
        requires :event_group_id, type: Integer, desc: "event_group id"
        requires :user_id, type: Integer, desc: "user id"
      end
      #-------------------------------------------------------------------------
      delete "/:event_group_id/user/:user_id" do 
        #/api/v1/group/:event_group_id/user/:user_id
      #-------------------------------------------------------------------------
        @event_group = EventGroup.first(:id => params[:event_group_id])
        error!('Event Group not found', 404) unless @event_group

        authorize! :delete_user_in_event_group, @event_group

        @user = User.first(:id => params[:user_id])
        error!('User not found', 404) unless @user

        # check if there is at least one guy with "group_admin" 
        # role in the event group
        group_admins_count = UserHasEventGroup.where(
          :event_group_id => params[:event_group_id],
          :user_role_id => "group_admin").count
        unless group_admins_count >= 1
          
          error!('Every event group needs at least one group admin', 409) 
        end
        
        @record = UserHasEventGroup.first(:user_id => params[:user_id],
          :event_group_id => params[:event_group_id])

        @record.delete if @record

        {:status => true}
      end

    end
  end
end