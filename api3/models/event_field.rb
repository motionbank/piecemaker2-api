class EventField < Sequel::Model(:event_fields)
  
  set_primary_key [:event_id, :id]

  
end