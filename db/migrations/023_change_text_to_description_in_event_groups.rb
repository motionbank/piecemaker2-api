Sequel.migration do
  up do
    alter_table(:event_groups) do
      rename_column(:text, :description)
    end    
  end

  down do
    alter_table(:event_groups) do
      rename_column(:description, :text)
    end
  end
end