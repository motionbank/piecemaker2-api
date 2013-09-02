module Piecemaker
  class API < Grape::API

    prefix 'api'

    format :json
    default_format :json

    version 'v1', using: :path, vendor: 'piecemaker'
    
    # rescue from all thrown exceptions,
    # return error code 500 and message with explanation
    rescue_from :all do |e|
      
      # @todo implement logging
      $stderr.puts e.message if ["development"].include?(ENV['RACK_ENV'])

      Rack::Response.new({
          'status' => 500,
          'message' => e.message,
          'param' => nil # e.param
      }.to_json, 500)
    end

    helpers Piecemaker::Helper::Auth
    
    mount ::Piecemaker::Users
    mount ::Piecemaker::EventGroups
    mount ::Piecemaker::Events
    mount ::Piecemaker::UserRoles
    mount ::Piecemaker::System
    

    if ENV['RACK_ENV'].to_sym == :development
      add_swagger_documentation api_version: 'v1'
    end

    if ENV['ENABLE_NEWRELIC']
      extend NewRelic::Agent::Instrumentation::Rack
    end
    
  end
end
