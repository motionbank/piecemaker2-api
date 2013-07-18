# http://sequel.rubyforge.org/rdoc/classes/Sequel/Model/Associations/ClassMethods.html

class User < Sequel::Model(:users)
  set_primary_key :id

  one_to_many :events, :key => :created_by_user_id

  many_to_many :event_groups,
    :join_table => :user_has_event_groups
  
end