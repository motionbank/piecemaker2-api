Sequel.migration do
  up do
    alter_table(:event_groups) do
      add_column :created_at, DateTime, :null => false
    end    
  end

  down do
    alter_table(:event_groups) do
      drop_column :created_at
    end
  end
end