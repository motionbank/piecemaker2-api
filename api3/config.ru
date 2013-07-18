require File.expand_path('../config/environment', __FILE__)

use Rack::SslEnforcer

if ENV['RACK_ENV'].to_sym == :development
  puts "Loading NewRelic in developer mode ..."
  require 'new_relic/rack/developer_mode'
  use NewRelic::Rack::DeveloperMode
end

NewRelic::Agent.manual_start

Rack::Handler::Thin.run(Piecemaker::App.instance, {Port: 3100}) do |server|
  # server.ssl = true 
  # server.ssl_options = {
  #     # :private_key_file => '/path/to/foo.key',
  #     # :cert_chain_file => '/path/to/bar.crt',
  #     :verify_peer => false,
  #   }
end

