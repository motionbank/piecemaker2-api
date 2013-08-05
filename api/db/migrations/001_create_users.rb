Sequel.migration do
  up do
    create_table(:users) do
      primary_key :id

      String :name, :size => 45, :null => false
      String :email, :size => 45, :unique => true
      String :password, :size => 45, :null => false
      String :api_access_key, :size => 45
      FalseClass :is_admin, :default => false
      FalseClass :is_disabled, :default => false
      
      unique [:email]

    end
  end

  down do
    drop_table(:users)
  end
end