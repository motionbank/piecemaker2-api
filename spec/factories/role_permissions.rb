# make entity random to avoid collission with init sql files

RolePermission.factory :allow do
  permission "allow"
  entity "random_SFHJ4432D_entity"
end

RolePermission.factory :forbid do
  permission "forbid"
  entity "random_SFHJ4432D_entity"
end