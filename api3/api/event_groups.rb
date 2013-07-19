module Piecemaker

  class EventGroups < Grape::API

    resource 'groups' do

      # --------------------------------------------------
      desc "all event_groups for currently logged in user"
      get "/" do
        @_user = authorize!
        # @todo acl!
        EventGroup.all || []
      end

    end

    resource 'group' do

      # --------------------------------------------------
      desc "create new event_group (together with user_has_event_groups record)"
      params do
        requires :id, type: Integer, desc: "event group id"
        requires :utc_timestamp, type: Float, desc: "utc timestamp"
        optional :duration, type: Float, desc: "duration"
        optional :fields, type: Hash, desc: "optional fields to create for this event {'field1': 'value', ...}"
      end 
      post "/:id/event" do
        @_user = authorize!
        # @todo acl!

        @event_group = EventGroup.first(:id => params[:id]) || error!('Not found', 404)

        @event = Event.create(
          :event_group_id     => @event_group.id,
          :created_by_user_id => @_user.id,
          :utc_timestamp      => params[:utc_timestamp],
          :duration           => params[:duration])

        # create event fields
        fields = []
        if params[:fields]
          params[:fields].each do |id, value|
            fields << EventField.create(
              :event_id => @event.id,
              :id       => id,
              :value    => value)
          end
        end
        
        [@event, fields]
      end

      # --------------------------------------------------
      desc "create new event_group (together with user_has_event_groups record)"
      params do
        requires :title, type: String, desc: "name of the group"
        requires :text, type: String, desc: "some additional description" # @todo type: Text not String
      end 
      post "/" do
        @_user = authorize!
        # @todo acl!

        @event_group = EventGroup.create(
          :title => params[:title],
          :text  => params[:text])

        UserHasEventGroup.create(
          :user_id => @_user.id,
          :event_group_id => @event_group.id)

        return @event_group
      end

      # --------------------------------------------------
      desc "returns event_group with id"
      params do
        requires :id, type: Integer, desc: "event group id"
      end
      get "/:id" do
        @_user = authorize!
        EventGroup.first(:id => params[:id]) || error!('Not found', 404)
      end

      # --------------------------------------------------
      desc "updates event_group with id"
      params do
        requires :id, type: Integer, desc: "event group id"
        optional :name, type: String, desc: "name of the group"
        optional :title, type: String, desc: "some additional description"

      end
      put "/:id" do
        @_user = authorize!
        @event_group = EventGroup.first(:id => params[:id])
        error!('Not found', 404) unless @event_group

        @event_group.update_with_params!(params, :name, :title)

        @event_group.save
      end

      # --------------------------------------------------
      desc "deletes event_group with id"
      params do
        requires :id, type: Integer, desc: "event_group id"
      end
      delete "/:id" do
        @_user = authorize!
        @event_group = EventGroup.first(:id => params[:id])
        error!('Not found', 404) unless @event_group

        @event_group.delete
      end

      # --------------------------------------------------
      desc "returns all events"
      params do
        requires :id, type: Integer, desc: "event group id"
      end
      get "/:id/events" do
        @_user = authorize!
        @event_group = EventGroup.first(:id => params[:id])
        error!('Not found', 404) unless @event_group

        Event.where(:event_group_id => @event_group.id)
      end

      # --------------------------------------------------
      desc "returns all users for event_group with id"
      params do
        requires :id, type: Integer, desc: "event group id"
      end
      get "/:id/users" do
        @_user = authorize!
        @event_group = EventGroup.first(:id => params[:id])
        error!('Not found', 404) unless @event_group

        @event_group.users

      end

    end

  end
end