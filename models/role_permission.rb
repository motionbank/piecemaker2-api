class RolePermission < Sequel::Model(:role_permissions)
  
  set_primary_key [:user_role_id, :permission, :action]

  set_dataset dataset.order(:action)

  one_to_one :user_role, :key => :id, :primary_key => :user_role_id

end