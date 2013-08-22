Event.factory :small do
  utc_timestamp 5.0 # @todo use real values
  duration 10.0
  type "marker"
end

Event.factory :big do
  utc_timestamp 20.0 # @todo use real values
  duration 7.0
  type "video"
end