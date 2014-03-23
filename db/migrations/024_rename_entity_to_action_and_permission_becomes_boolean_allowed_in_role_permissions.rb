Sequel.migration do
  up do
    alter_table(:role_permissions) do
      rename_column(:entitiy, :action)
      drop_column :permission
      add_column :allowed, TrueClass, :null => false, :default => false

      # http://sequel.jeremyevans.net/rdoc/files/doc/schema_modification_rdoc.html
      # note that for boolean columns, you can use either TrueClass or FalseClass, 
      # they are treated the same way (ruby doesn't have a Boolean class).
    end    
  end

  down do
    alter_table(:role_permissions) do
      rename_column(:action, :entitiy)
      add_column :permission, String, :size => 50, :null => false
      drop_column :allowed
    end
  end
end