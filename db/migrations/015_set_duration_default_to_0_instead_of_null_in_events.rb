Sequel.migration do
  up do
    alter_table(:events) do
      set_column_default :duration, 0
      set_column_not_null :duration
    end
  end

  down do
    alter_table(:events) do
      set_column_allow_null :duration
      set_column_default :duration, nil
    end
  end
end