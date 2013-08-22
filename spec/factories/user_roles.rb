UserRole.factory :admin do
  id "admin"
  description "i am the boss"
end

UserRole.factory :user do
  id "user"
  description "default user"
end

UserRole.factory :guest do
  id "guest"
  description "only guest access"
end