Sequel.migration do
  up do
    create_table(:event_groups) do
      primary_key :id

      String :title, :size => 255
      String :text, :text => true

    end
  end

  down do
    drop_table(:event_groups)
  end
end