Event.unrestrict_primary_key

Event.factory :in_groupa do
  utc_timestamp 987.123456
  duration 789.654321
end

Event.factory :in_groupb1 do
  utc_timestamp 987.123456
  duration 789.654321
end

Event.factory :in_groupb2 do
  utc_timestamp 123.456
  duration 456.123
end