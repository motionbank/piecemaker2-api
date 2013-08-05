module Piecemaker

  class Events < Grape::API

    #===========================================================================
    resource 'event' do #=======================================================
    #===========================================================================
 

      #_________________________________________________________________________
      ##########################################################################
      desc "returns event with id"
      #-------------------------------------------------------------------------
      params do
        requires :id, type: Integer, desc: "event id"
      end
      #-------------------------------------------------------------------------
      get "/:id" do  #/api/v1/event/:id
      #-------------------------------------------------------------------------
        @_user = authorize!
        @event = Event.first(:id => params[:id]) || error!('Not found', 404)
        
        { :event => @event, 
          :fields => @event.event_fields }
      end


      #_________________________________________________________________________
      ##########################################################################
      desc "updates an event with id"
      #-------------------------------------------------------------------------
      params do
        requires :id, type: Integer, desc: "event group id"
        requires :utc_timestamp, type: Float, desc: "utc timestamp"
        optional :duration, type: Float, desc: "duration"
        optional :fields, type: Hash, desc: "optional fields to create for this event {'field1': 'value', ...}"
      end
      #-------------------------------------------------------------------------
      put "/:id" do  #/api/v1/event/:id
      #-------------------------------------------------------------------------
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

              EventField.unrestrict_primary_key

              # create new field
              EventField.create(
                :event_id => @event.id, 
                :id => id,
                :value => value)
            end
          end
        end

        {
          :event => @event, 
          :fields => EventField.where(:event_id => @event.id)
        }
      end


      #_________________________________________________________________________
      ##########################################################################
      desc "deletes event with id"
      #-------------------------------------------------------------------------
      params do
        requires :id, type: Integer, desc: "event id"
      end
      #-------------------------------------------------------------------------
      delete "/:id" do  #/api/v1/event/:id
      #-------------------------------------------------------------------------
        @_user = authorize!
        @event = Event.first(:id => params[:id])
        error!('Not found', 404) unless @event

        { :event => @event.delete, :fields => [] }
      end

    end
  end
end