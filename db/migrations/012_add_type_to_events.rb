Sequel.migration do
  up do
    alter_table(:events) do
      add_column :type, String, :size => 50, :null => false
    end    
  end

  down do
    alter_table(:events) do
      drop_column :type
    end
  end
end