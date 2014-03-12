require "digest"

User.factory :peter do
  name "Peter"
  email "peter@example.com"
  password Digest::SHA1.hexdigest("Peter") # important, that password == name
  api_access_key Piecemaker::Helper::API_Access_Key::generate
  user_role_id "user"
end

User.factory :pan do
  name "Pan"
  email "pan@example.com"
  password Digest::SHA1.hexdigest("Pan") # important, that password == name
  api_access_key Piecemaker::Helper::API_Access_Key::generate
  user_role_id "user"
end

User.factory :hans_admin do
  name "Hans"
  email "hans@example.com"
  password Digest::SHA1.hexdigest("Hans") # important, that password == name
  api_access_key Piecemaker::Helper::API_Access_Key::generate
  user_role_id "(RSPEC_PREFIX)-admin"
end

User.factory :klaus_disabled do
  name "Klaus"
  email "klaus@example.com"
  password Digest::SHA1.hexdigest("Klaus") # important, that password == name
  api_access_key Piecemaker::Helper::API_Access_Key::generate
  user_role_id "user"
  is_disabled true
end

User.factory :user_with_no_api_access_key do
  name "User without API Access Key"
  email "user_with_no_api_access_key@example.com"
  password Digest::SHA1.hexdigest("User without API Access Key") # important, that password == name
  api_access_key nil
  user_role_id "user"
  is_disabled false
end
