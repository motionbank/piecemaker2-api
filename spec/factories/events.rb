Event.factory :small do
  utc_timestamp 5.0
  duration 10.0
  type "small"
end

Event.factory :big do
  utc_timestamp 20.0
  duration 7.0
  type "big"
end