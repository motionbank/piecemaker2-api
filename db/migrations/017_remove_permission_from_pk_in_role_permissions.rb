Sequel.migration do
  up do
    drop_table(:role_permissions)

    create_table(:role_permissions) do
      String :user_role_id, :size => 50, :null => false
      String :permission, :size => 50, :null => false
      String :entity, :size => 50, :null => false
      primary_key [:user_role_id, :entity]
    end

    alter_table(:role_permissions) do
      add_foreign_key([:user_role_id], :user_roles, :key => :id, 
        :on_delete => :cascade, :on_update => :cascade)
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

    alter_table(:role_permissions) do
      add_foreign_key([:user_role_id], :user_roles, :key => :id, 
        :on_delete => :cascade, :on_update => :cascade)
    end
  end
end