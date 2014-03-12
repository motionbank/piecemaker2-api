Sequel.migration do
  up do
    alter_table(:users) do
      drop_column :is_super_admin
    end    
  end

  down do
    alter_table(:users) do
      FalseClass :is_super_admin, :default => false, :null => false
    end
  end
end