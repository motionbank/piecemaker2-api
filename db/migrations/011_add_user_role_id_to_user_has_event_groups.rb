Sequel.migration do
  up do
    alter_table(:user_has_event_groups) do
      add_column :user_role_id, String, :size => 50, :null => true
      add_foreign_key([:user_role_id], :user_roles, :key => :id, 
        :on_delete => :set_null, :on_update => :set_null)
    end
  end

  down do
    alter_table(:user_has_event_groups) do
      drop_foreign_key([:user_role_id])
      drop_column :user_role_id
    end
  end
end