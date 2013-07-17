Sequel.migration do
  up do
    create_table(:event_groups) do
      Integer :id
      String :title, :size => 255
      String :text, :text => true
      
      primary_key [:id]
      
    end
  end

  down do
    drop_table(:event_groups)
  end
end