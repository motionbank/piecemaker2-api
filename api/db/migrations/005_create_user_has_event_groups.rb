Sequel.migration do
  up do
    create_table(:user_has_event_groups) do
      Integer :user_id
      Integer :event_group_id

      FalseClass :allow_create, :default => false
      FalseClass :allow_read, :default => false
      FalseClass :allow_update, :default => false
      FalseClass :allow_delete, :default => false
      
      primary_key [:user_id, :event_group_id]
      
    end
  end

  down do
    drop_table(:user_has_event_groups)
  end
end