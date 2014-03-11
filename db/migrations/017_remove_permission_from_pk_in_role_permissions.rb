Sequel.migration do
  up do
    drop_table(:role_permissions)

    create_table(:role_permissions) do
      String :user_role_id, :size => 50, :null => false
      String :permission, :size => 50, :null => false
      String :entity, :size => 50, :null => false
      primary_key [:user_role_id, :entity]
    end
  end

  down do
    drop_table(:role_permissions)

    create_table(:role_permissions) do
      String :user_role_id, :size => 50, :null => false
      String :permission, :size => 50, :null => false
      String :entity, :size => 50, :null => false
      primary_key [:user_role_id, :permission, :entity]
    end
  end
end