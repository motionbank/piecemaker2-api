# prefix id to avoid collission with init sql files

prefix = "(RSPEC_PREFIX)-"

UserRole.factory :admin do
  id prefix + "admin"
  inherit_from_id prefix + "user"
  description "i am the boss"
end

UserRole.factory :user do
  id prefix + "user"
  inherit_from_id  prefix + "guest"
  description "default user"
end

UserRole.factory :guest do
  id prefix + "guest"
  inherit_from_id nil
  description "only guest access"
end