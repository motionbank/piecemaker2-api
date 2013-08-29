class EventGroup < Sequel::Model(:event_groups)
  
  set_primary_key :id

  set_dataset dataset.order(:created_at)

  one_to_many :events
  many_to_many :users, :join_table => :user_has_event_groups
  
  many_to_one :user, :key => :created_by_user_id, :primary_key => :id

  def before_create
    self.created_at ||= Time.now.utc
    super
  end
end