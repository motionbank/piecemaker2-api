require File.expand_path('../config/environment', __FILE__)

if ENV['RACK_ENV'].to_sym == :development
  puts "Loading NewRelic in developer mode ..."
  require 'new_relic/rack/developer_mode'
  use NewRelic::Rack::DeveloperMode
end

NewRelic::Agent.manual_start

run Piecemaker::App.instance

