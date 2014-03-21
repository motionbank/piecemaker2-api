module Piecemaker

  class Events < Grape::API

    #===========================================================================
    resource 'event' do #=======================================================
    #===========================================================================
 

      #_________________________________________________________________________
      ##########################################################################
      desc "returns event with id" +
           " (requires get_events permission)"
      #-------------------------------------------------------------------------
      params do
        requires :id, type: Integer, desc: "event id"
      end
      #-------------------------------------------------------------------------
      get "/:id" do  #/api/v1/event/:id
      #-------------------------------------------------------------------------
        @event = Event.first(:id => params[:id])
        error!('Not found', 404) unless @event
        authorize! :get_events, @event
        
        {:fields => @event.event_fields || [] }.merge(@event)
      end


      #_________________________________________________________________________
      ##########################################################################
      desc "updates an event with id" +
           " (requires update_event permission)"
      #-------------------------------------------------------------------------
      params do
        requires :id, type: Integer, desc: "event id"
        requires :utc_timestamp, type: Float, desc: "utc timestamp"
        optional :duration, type: Float, desc: "duration"
        optional :type, type: String, desc: "type of event"
        optional :fields, type: Hash, desc: "optional fields to update for this event {'field1': 'value', ...}"
        requires :token, type: String, desc: "pass-through token from initial request"
      end
      #-------------------------------------------------------------------------
      put "/:id" do  #/api/v1/event/:id
      #-------------------------------------------------------------------------
        @event = Event.first(:id => params[:id])
        error!('Not found', 404) unless @event
        authorize! :update_event, @event

        verify_token! @event

        begin
          DB.transaction(:rollback => :reraise) do
            @event.update_with_params!(params, :utc_timestamp, :duration, :type)
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

                  EventField.unrestrict_primary_key

                  # create new field
                  EventField.create(
                    :event_id => @event.id, 
                    :id => id,
                    :value => value)
                end
              end
            end
          end
        rescue # Sequel::Rollback
          error!('Internal Server Error', 500)
        else
          return {
            :fields => EventField.where(:event_id => @event.id) || []
          }.merge(@event)
        end
      end


      #_________________________________________________________________________
      ##########################################################################
      desc "deletes event with id" +
           " (requires delete_event permission)"
      #-------------------------------------------------------------------------
      params do
        requires :id, type: Integer, desc: "event id"
      end
      #-------------------------------------------------------------------------
      delete "/:id" do  #/api/v1/event/:id
      #-------------------------------------------------------------------------
        @event = Event.first(:id => params[:id])
        error!('Not found', 404) unless @event

        authorize! :delete_event, @event

        { :event => @event.delete, :fields => [] }
      end

    end
  end
end