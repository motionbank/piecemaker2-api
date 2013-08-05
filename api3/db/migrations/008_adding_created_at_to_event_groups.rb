Sequel.migration do
  up do
    alter_table(:event_groups) do
      add_column :created_at, DateTime, :null => false, :default => Time.now
    end    
  end

  down do
    alter_table(:event_groups) do
      drop_column :created_at
    end
  end
end