# http://sequel.rubyforge.org/rdoc/classes/Sequel/Model/Associations/ClassMethods.html
# http://sequel.rubyforge.org/rdoc/files/doc/association_basics_rdoc.html

class User < Sequel::Model(:users)
  set_primary_key :id
  set_dataset dataset.order(:name)

  one_to_many :events, :key => :created_by_user_id

  many_to_many :event_groups,
    :join_table => :user_has_event_groups
  
end

# user_id, can,  in
# 1,       read, event_groups(id)
# 1        read, event_groups
# 1,       write, event_groups()