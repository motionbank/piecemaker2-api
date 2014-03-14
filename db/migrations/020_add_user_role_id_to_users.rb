Sequel.migration do
  up do
    alter_table(:users) do
      add_column :user_role_id, String, :size => 50, :null => false, :default => "user"
      add_foreign_key([:user_role_id], :user_roles, :key => :id, 
        :on_delete => :restrict, :on_update => :cascade)
    end    
  end

  down do
    alter_table(:users) do
      drop_foreign_key([:user_role_id])
      drop_column :user_role_id
    end
  end
end