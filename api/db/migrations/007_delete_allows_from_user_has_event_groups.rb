Sequel.migration do
  up do
    alter_table(:user_has_event_groups) do
      drop_column :allow_create
      drop_column :allow_read
      drop_column :allow_update
      drop_column :allow_delete
    end
  end

  down do
    alter_table(:user_has_event_groups) do
      add_column :allow_create, FalseClass, :default => false
      add_column :allow_read, FalseClass, :default => false
      add_column :allow_update, FalseClass, :default => false
      add_column :allow_delete, FalseClass, :default => false
    end
  end
end