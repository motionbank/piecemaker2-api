class Event < Sequel::Model(:events)
  
  set_primary_key :id

  many_to_one :user, :key => :created_by_user_id


  one_to_many :event_fields
  one_to_one :event_group, :key => :id

end