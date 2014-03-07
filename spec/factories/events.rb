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

# Events for fromto_query tests
# see docs/fromto_query.md

Event.factory :event1 do
  utc_timestamp 8.0
  duration 8.0
  type 'fromto_query_test'
end
Event.factory :event2 do
  utc_timestamp 13.0
  duration 9.0
  type 'fromto_query_test'
end
Event.factory :event3 do
  utc_timestamp 17.0
  duration 9.0
  type 'fromto_query_test'
end
Event.factory :event4 do
  utc_timestamp 28.0
  duration 3.0
  type 'fromto_query_test'
end