Sequel.migration do
  up do
    alter_table(:events) do
      add_column :token, String, :size => 10, :null => true
    end    
  end

  down do
    alter_table(:events) do
      drop_column :token
    end
  end
end