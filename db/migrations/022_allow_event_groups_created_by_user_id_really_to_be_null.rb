Sequel.migration do
  up do
    alter_table(:event_groups) do
      set_column_allow_null :created_by_user_id
    end
  end

  down do
    alter_table(:event_groups) do
      set_column_not_null :created_by_user_id
    end
  end
end