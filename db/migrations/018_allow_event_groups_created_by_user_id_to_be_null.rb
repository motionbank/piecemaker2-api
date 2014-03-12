Sequel.migration do
  up do
    drop_foreign_key([:created_by_user_id])
    add_foreign_key([:created_by_user_id], :users, :key => :id, 
      :on_delete => :set_null, :on_update => :cascade)
  end

  down do
    drop_foreign_key([:created_by_user_id])
    add_foreign_key([:created_by_user_id], :users, :key => :id, 
      :on_delete => :restrict, :on_update => :cascade)
  end
end