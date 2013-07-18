class Event < Sequel::Model(:events)
  
  set_primary_key :id

  many_to_one :user, :primary_key => :created_by_user_id


end