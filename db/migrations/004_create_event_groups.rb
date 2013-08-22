Sequel.migration do
  up do
    create_table(:event_groups) do
      primary_key :id

      String :title, :size => 255, :null => false
      String :text, :text => true, :null => true

    end
  end

  down do
    drop_table(:event_groups)
  end
end