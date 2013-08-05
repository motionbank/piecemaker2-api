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
        # @todo acl!
        EventGroup.eager_graph(:users).where(:user_id => @_user.id)
      end
    end


    #===========================================================================
    resource 'group' do #=======================================================
    #===========================================================================
      

      #_________________________________________________________________________
      ##########################################################################
      desc "creates and returns new event and event_fields"
      #-------------------------------------------------------------------------
      params do
        requires :id, type: Integer, desc: "event group id"
        requires :utc_timestamp, type: Float, desc: "utc timestamp"
        optional :duration, type: Float, desc: "duration"
        optional :fields, type: Hash, desc: "optional fields to create for this event {'field1': 'value', ...}"
      end 
      #-------------------------------------------------------------------------
      post "/:id/event" do  #/api/v1/group/:id/event
      #-------------------------------------------------------------------------
        @_user = authorize!
        # @todo acl!

        @event_group = EventGroup.first(
          :id => params[:id]) || error!('Not found', 404)

        @event = Event.create(
          :event_group_id     => @event_group.id,
          :created_by_user_id => @_user.id,
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
      desc "create new event_group (together with user_has_event_groups record)"
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
        # @todo acl!

        @event_group = EventGroup.create(
          :title => params[:title],
          :text  => params[:text])

        UserHasEventGroup.unrestrict_primary_key
        UserHasEventGroup.create(
          :user_id => @_user.id,
          :event_group_id => @event_group.id)

        return @event_group
      end
      

      #_________________________________________________________________________
      ##########################################################################
      desc "returns event_group with id"
      #-------------------------------------------------------------------------
      params do
        requires :id, type: Integer, desc: "event group id"
      end
      #-------------------------------------------------------------------------
      get "/:id" do  #/api/v1/group/:id
      #-------------------------------------------------------------------------
        @_user = authorize!
        EventGroup.first(:id => params[:id]) || error!('Not found', 404)
      end
      

      #_________________________________________________________________________
      ##########################################################################
      desc "updates event_group with id"
      #-------------------------------------------------------------------------
      params do
        requires :id, type: Integer, desc: "event group id"
        optional :name, type: String, desc: "name of the group"
        optional :title, type: String, desc: "some additional description"
      end
      #-------------------------------------------------------------------------
      put "/:id" do  #/api/v1/group/:id
      #-------------------------------------------------------------------------
        @_user = authorize!
        @event_group = EventGroup.first(:id => params[:id])
        error!('Not found', 404) unless @event_group

        @event_group.update_with_params!(params, :name, :title)

        @event_group.save
      end
      

      #_________________________________________________________________________
      ##########################################################################
      desc "deletes event_group with id"
      #-------------------------------------------------------------------------
      params do
        requires :id, type: Integer, desc: "event_group id"
      end
      #-------------------------------------------------------------------------
      delete "/:id" do #/api/v1/group/:id
      #-------------------------------------------------------------------------
        @_user = authorize!
        @event_group = EventGroup.first(:id => params[:id])
        error!('Not found', 404) unless @event_group

        @event_group.delete
      end
       

      #_________________________________________________________________________
      ##########################################################################
      desc "returns all events (filter options are connect with AND)"
      #-------------------------------------------------------------------------
      params do
        requires :id, type: Integer, desc: "event group id"
        optional :from, type: Float, desc: ">= utc_timestamp"
        optional :to, type: Float, desc: "<= utc_timestamp"
        optional :field, type: Hash, desc: "filter by event field key"
      end
      #-------------------------------------------------------------------------
      get "/:id/events" do  #/api/v1/group/:id/events
      #-------------------------------------------------------------------------
        @_user = authorize!
        @event_group = EventGroup.first(:id => params[:id])
        error!('Not found', 404) unless @event_group

        # @†odo refactor!
        # [05.08.13 20:42:11] Matthias Kadenbach: ?field[type]=video&field[rating]=1
        # [05.08.13 20:43:24] Matthias Kadenbach: ?field[type]=video&field[rating]
        # 
        # combine everything
        # paging

        if params[:from] && params[:to]

          # find by from - to

          @events = Event.where( :event_group_id => @event_group.id )

          @return_events = []
          @events.each do |event|
            ev = JSON.parse(event.to_json, {:symbolize_names => true})
            if ev[:utc_timestamp] >= params[:from] && ev[:utc_timestamp] <= params[:to]
              @return_events << { :event => ev, 
                :fields => EventField.where(:event_id => event[:id])}
            end
          end

          return @return_events

        elsif params[:field]

          # find by field { type => value }

          @events = Event.where( :event_group_id => @event_group.id )

          @return_events = []
          @events.each do |event|

            @event_fields = EventField.where(
              :event_id => event.id).to_hash(:id, :value)
            
            counter = 0
            params[:field].each do |id, value|
              if @event_fields.has_key?(id) && @event_fields[id] == value
                counter += 1
              end
            end
            if counter == params[:field].length
              @return_events << { 
                :event => event, 
                :fields => EventField.where(:event_id => event.id) }
            end


          end

          return @return_events

        else

          # get all events

          @events = Event.where( :event_group_id => @event_group.id )
          @return_events = []
          @events.each do |event|
            @return_events << { :event => event, 
              :fields => EventField.where(:event_id => event.id) }
          end

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
        @_user = authorize!
        @event_group = EventGroup.first(:id => params[:id])
        error!('Not found', 404) unless @event_group

        @event_group.users
      end


      #_________________________________________________________________________
      ##########################################################################
      desc "adds a user to an event_group"
      #-------------------------------------------------------------------------
      params do
        requires :event_group_id, type: Integer, desc: "event_group id"
        requires :user_id, type: Integer, desc: "user id"
      end
      #-------------------------------------------------------------------------
      post "/:event_group_id/user/:user_id" do 
        #/api/v1/group/:event_group_id/user/:user_id
      #-------------------------------------------------------------------------
        @_user = authorize!
        @event_group = EventGroup.first(:id => params[:event_group_id])
        error!('Event Group not found', 404) unless @event_group

        @user = User.first(:id => params[:user_id])
        error!('User not found', 404) unless @user
        
        UserHasEventGroup.unrestrict_primary_key
        UserHasEventGroup.create(:user_id => params[:user_id],
          :event_group_id => params[:event_group_id])

        {:status => true}
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
        @_user = authorize!
        @event_group = EventGroup.first(:id => params[:event_group_id])
        error!('Event Group not found', 404) unless @event_group

        @user = User.first(:id => params[:user_id])
        error!('User not found', 404) unless @user
        
        @record = UserHasEventGroup.first(:user_id => params[:user_id],
          :event_group_id => params[:event_group_id])

        @record.delete if @record

        {:status => true}
      end

    end
  end
end