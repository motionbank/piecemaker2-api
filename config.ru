require File.expand_path('../config/environment', __FILE__)

# use Rack::SslEnforcer

if ENV['ENABLE_NEWRELIC']
  puts "Loading NewRelic ..."
  if ENV['NEW_RELIC_LICENSE_KEY']
    require 'new_relic/rack/developer_mode'
    use NewRelic::Rack::DeveloperMode
  else
    puts "Missing NewRelic license key in config" 
  end
end

NewRelic::Agent.manual_start

use Rack::Deflater

use Rack::Cors do
  allow do
    origins '*'

    resource '*', :headers => :any, :methods => [:get, :post, :put, :delete, :options]
  end
end

run Piecemaker::App.instance

#Rack::Handler::Thin.run(Piecemaker::App.instance) do |server|
  # server.ssl = true 
  # server.ssl_options = {
  #     # :private_key_file => '/path/to/foo.key',
  #     # :cert_chain_file => '/path/to/bar.crt',
  #     :verify_peer => false,
  #   }
#end

