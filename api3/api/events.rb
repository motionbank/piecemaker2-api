module Piecemaker

  class Events < Grape::API

    resource 'event' do

      # --------------------------------------------------
      desc "returns event with id"
      params do
        requires :id, type: Integer, desc: "event id"
      end
      get "/:id" do
        @_user = authorize!
        Event.first(:id => params[:id]) || error!('Not found', 404)
        # @todo return group as well
      end

      # --------------------------------------------------
      desc "updates an event with id"
      params do
        requires :id, type: Integer, desc: "event group id"
        requires :utc_timestamp, type: Float, desc: "utc timestamp"
        optional :duration, type: Float, desc: "duration"
        optional :fields, type: Hash, desc: "optional fields to create for this event {'field1': 'value', ...}"
      end
      put "/:id" do
        @_user = authorize!
        @event = Event.first(:id => params[:id])
        error!('Not found', 404) unless @event

        # @todo wrap this into transaction

        @event.update_with_params!(params, :utc_timestamp, :duration)
        @event.save

        @event_fields = EventField.where(:event_id => @event.id)
        event_fields_hash = @event_fields.to_hash(:id, :value)

      
        if params[:fields]
          params[:fields].each do |id, value|
            if event_fields_hash.has_key? id
              if value == "null"
                # delete field
                EventField.first(:event_id => @event.id, :id => id).delete
              else
                # update field
                EventField.first(
                  :event_id => @event.id, 
                  :id => id).update(:value => value)
              end
            else
              # create new field
              EventField.create(
                :event_id => @event.id, 
                :id => id,
                :value => value)
            end
          end
        end

=begin

        if @event_fields
          @event_fields.each do |event_field|
            # puts event_field.values.inspect
          end
        end

        fields = []
        if params[:fields]
          params[:fields].each do |id, value|
            # try to find event field
            @event_field = EventField.first(
              :event_id => @event.id,
              :id => id)
            # nil deletes
            if @event_field
              # update existing event field
              if @event_field.value != value
                @event_field.value = value
                @event_field.save
              end
            else
              # create new event field
              @event_field = EventField.create(
                :event_id => @event.id,
                :id => id,
                :value => value)
            end

            fields << @event_field
          end
        end
=end

        [@event, EventField.where(:event_id => @event.id)]
        
      end

      # --------------------------------------------------
      desc "deletes event with id"
      params do
        requires :id, type: Integer, desc: "event id"
      end
      delete "/:id" do
        @_user = authorize!
        @event = Event.first(:id => params[:id])
        error!('Not found', 404) unless @event

        @event.delete
      end

      # --------------------------------------------------
      desc "creates a new field for event"
      params do
        requires :id, type: Integer, desc: "event id"
        requires :key, type: String, desc: "key name (alias event_fields.id)"
        requires :value, type: String, desc: "value to save" # @todo Text not String
      end
      post "/:id/field" do
        @_user = authorize!
        @event = Event.first(:id => params[:id])
        error!('Not found', 404) unless @event

        
      end

    end

  end
end