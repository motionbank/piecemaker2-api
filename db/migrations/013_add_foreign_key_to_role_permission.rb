Sequel.migration do
  up do
    alter_table(:role_permissions) do
      add_foreign_key([:user_role_id], :user_roles, :key => :id, 
        :on_delete => :cascade, :on_update => :cascade)
    end
  end

  down do
    alter_table(:role_permissions) do
      drop_foreign_key([:user_role_id])
    end
  end
end