class UserRole < Sequel::Model(:user_roles)
  set_primary_key :id
  set_dataset dataset.order(:id)

  one_to_many :user_has_event_groups, :key => :user_role_id
  one_to_many :users, :key => :user_role_id

  one_to_many :role_permissions, :key => :user_role_id
  
end