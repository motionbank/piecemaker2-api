
Event.unrestrict_primary_key

Event.factory :big do
  utc_timestamp 5.0
  duration 789.654321
end

Event.factory :small do
  utc_timestamp 20.0
  duration 789.654321
end
