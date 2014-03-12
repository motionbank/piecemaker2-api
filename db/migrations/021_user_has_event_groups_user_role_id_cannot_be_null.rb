Sequel.migration do
  up do
    alter_table(:user_has_event_groups) do
      set_column_not_null :user_role_id
    end
  end

  down do
    alter_table(:user_has_event_groups) do
      set_column_allow_null :user_role_id
    end
  end
end