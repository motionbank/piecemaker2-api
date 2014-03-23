# make action random to avoid collission with init sql files

RolePermission.factory :allow do
  allowed true
  action "random_SFHJ4432D_action"
end

RolePermission.factory :forbid do
  allowed false
  action "random_SFHJ4432D_action"
end

RolePermission.factory :invalid_permission_type do
  allowed "invalid_type"
  action "random_SFHJ4432D_action"
end