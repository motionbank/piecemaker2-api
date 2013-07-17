Sequel.migration do
  up do
    alter_table(:events) do
      add_foreign_key([:event_group_id], :event_groups, :key => :id)
      add_foreign_key([:created_by_user_id], :users, :key => :id)
    end

    alter_table(:event_fields) do
      add_foreign_key([:event_id], :events, :key => :id)
    end

    alter_table(:user_has_event_groups) do
      add_foreign_key([:user_id], :users, :key => :id)
      add_foreign_key([:event_group_id], :event_groups, :key => :id)
    end
    
  end

  down do
    alter_table(:events) do
      drop_foreign_key([:event_group_id])
      drop_foreign_key([:created_by_user_id])
    end

    alter_table(:event_fields) do
      drop_foreign_key([:event_id])
    end

    alter_table(:user_has_event_groups) do
      drop_foreign_key([:user_id])
      drop_foreign_key([:event_group_id])
    end
  end
end