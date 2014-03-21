EventGroup.factory :alpha do
  title "Group A"
  description "Event Group Alpha"
  created_at "2012-08-05 13:15:23 +0200"
end

EventGroup.factory :beta do
  title "Group B"
  description "Event Group Beta"
end

# Events for fromto_query tests
# see docs/fromto_query.md

EventGroup.factory :tofrom_query do
  title "Group for tofrom_query tests"
  description "see title ;-)"
end