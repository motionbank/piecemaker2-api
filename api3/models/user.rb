class User < Sequel::Model(:users)
  set_primary_key :id

  one_to_many :events, :key => :created_by_user_id
  
  
end