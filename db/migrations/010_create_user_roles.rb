Sequel.migration do
  up do
    create_table(:user_roles) do

      String :id, :size => 50
      String :description, :text => true, :null => true

      primary_key [:id]
      
    end
  end

  down do
    drop_table(:user_roles)
  end
end