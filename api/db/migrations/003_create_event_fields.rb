Sequel.migration do
  up do
    create_table(:event_fields) do
      Integer :event_id
      String :id, :size => 32 #, :fixed => true
      String :value, :text => true
      
      primary_key [:event_id, :id]
      
    end
  end

  down do
    drop_table(:event_fields)
  end
end