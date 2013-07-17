Event.factory :in_groupa do
  id 31
  event_group_id 21
  created_by_user_id 1001 # peter
  utc_timestamp 987.123456
  duration 789.654321
end

Event.factory :in_groupb1 do
  id 35
  event_group_id 22
  created_by_user_id 1002 # pan
  utc_timestamp 987.123456
  duration 789.654321
end

Event.factory :in_groupb2 do
  id 36
  event_group_id 22
  created_by_user_id 1001 # peter
  utc_timestamp 123.456
  duration 456.123
end