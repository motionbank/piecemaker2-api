require File.expand_path('../config/environment', __FILE__)

#Rack::Handler::Thin.run(Piecemaker::App.instance) do |server|
  # server.ssl = true 
  # server.ssl_options = {
  #     # :private_key_file => '/path/to/foo.key',
  #     # :cert_chain_file => '/path/to/bar.crt',
  #     :verify_peer => false,
  #   }
#end


# use Rack::SslEnforcer
use Rack::Deflater

use Rack::Cors do
  allow do
    origins '*'
    resource '*', :headers => :any, 
      :methods => [:get, :post, :put, :delete, :options]
  end
end


if ENV['ENABLE_NEWRELIC']
  puts "Loading NewRelic ..."
  require 'newrelic_rpm'
  require 'new_relic/rack/developer_mode'

  puts "NewRelic Developer Mode: " + ENV["NEWRELIC_DEVELOPER"]
  puts "NewRelic Monitor Mode: " + ENV["NEWRELIC_MONITOR"]

  if ENV["NEWRELIC_MONITOR"] and not ENV['NEWRELIC_LICENSE_KEY']
    puts "Error: Missing NewRelic license key in config!" 
  end

  use NewRelic::Rack::DeveloperMode
  NewRelic::Agent.manual_start
end


run Piecemaker::API

