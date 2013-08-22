Sequel.migration do
  up do
    create_table(:event_fields) do
      Integer :event_id, :null => false
      String :id, :size => 50, :null => false #, :fixed => true
      String :value, :text => true, :null => true, :default => nil
      
      primary_key [:event_id, :id]
      
    end
  end

  down do
    drop_table(:event_fields)
  end
end