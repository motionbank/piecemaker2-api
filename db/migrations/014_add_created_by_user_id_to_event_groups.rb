Sequel.migration do
  up do
    alter_table(:event_groups) do
      add_column :created_by_user_id, Integer, :null => false
      add_foreign_key([:created_by_user_id], :users, :key => :id, 
        :on_delete => :restrict, :on_update => :cascade)
    end
  end

  down do
    alter_table(:event_groups) do
      drop_foreign_key([:created_by_user_id])
      drop_column :created_by_user_id
    end
  end
end