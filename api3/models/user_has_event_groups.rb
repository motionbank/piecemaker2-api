class UserHasEventGroup < Sequel::Model(:user_has_event_groups)
  
  set_primary_key [:user_id, :event_group_id]

  one_to_one :user, :key => :id, :primary_key => :user_id
  one_to_one :event_group, :key => :id, :primary_key => :event_group_id
end