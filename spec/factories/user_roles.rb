# make id random to avoid collission with init sql files

UserRole.factory :admin do
  id "my_random_DBIK342sd_admin"
  inherit_from_id "my_random_FSFDF24233_user"
  description "i am the boss"
end

UserRole.factory :user do
  id "my_random_FSFDF24233_user"
  inherit_from_id "my_random_SDFSDsadf1_guest"
  description "default user"
end

UserRole.factory :guest do
  id "my_random_SDFSDsadf1_guest"
  inherit_from_id nil
  description "only guest access"
end