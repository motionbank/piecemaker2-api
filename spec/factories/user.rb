require "digest"

User.factory :peter do
  name "Peter"
  email "peter@example.com"
  password Digest::SHA1.hexdigest("Peter") # important, that password == name
  api_access_key Piecemaker::Helper::API_Access_Key::generate
  is_admin false
end

User.factory :pan do
  name "Pan"
  email "pan@example.com"
  password Digest::SHA1.hexdigest("Pan") # important, that password == name
  api_access_key Piecemaker::Helper::API_Access_Key::generate
  is_admin false
end

User.factory :hans_admin do
  name "Hans"
  email "hans@example.com"
  password Digest::SHA1.hexdigest("Hans") # important, that password == name
  api_access_key Piecemaker::Helper::API_Access_Key::generate
  is_admin true
end

User.factory :klaus_disabled do
  name "Klaus"
  email "klaus@example.com"
  password Digest::SHA1.hexdigest("Klaus") # important, that password == name
  api_access_key Piecemaker::Helper::API_Access_Key::generate
  is_admin false
  is_disabled true
end
