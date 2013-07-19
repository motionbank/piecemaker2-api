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

        fields = []
        if params[:fields]
          params[:fields].each do |id, value|
            # try to find event field
            @event_field = EventField.first(
              :event_id => @event.id,
              :id => id)

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
        
        [@event, fields]
        
      end

    end

  end
end