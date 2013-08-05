class EventField < Sequel::Model(:event_fields)
  
  set_primary_key [:event_id, :id]
  set_dataset dataset.order(:id)

  one_to_one :event, :key => :id, :primary_key => :event_id
  
end