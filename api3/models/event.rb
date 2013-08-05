class Event < Sequel::Model(:events)
  
  set_primary_key :id

  set_dataset dataset.order(:utc_timestamp)

  many_to_one :user, :key => :created_by_user_id, :primary_key => :id

  one_to_many :event_fields
  many_to_one :event_group, :key => :event_group_id, :primary_key => :id

end