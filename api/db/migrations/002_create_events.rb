Sequel.migration do
  up do
    create_table(:events) do
      primary_key :id

      Integer :event_group_id, :null => false
      Integer :created_by_user_id

      # BigDecimal :utc_timestamp, :size => [20, 6], :null => false
      # BigDecimal :duration, :size => [11, 6], :null => true      

      Float :utc_timestamp, :null => false
      Float :duration, :null => true
      
    end
  end

  down do
    drop_table(:events)
  end
end