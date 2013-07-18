module Piecemaker
  class API < Grape::API

    # rescue errors coming from sequel
    rescue_from Sequel::DatabaseError do |e|
      # @todo: implement logging
      $stderr.puts e.message if ["test", "development"].include?(ENV['RACK_ENV'])
      Rack::Response.new({
          'status' => 500,
          'message' => e.message,
          'param' => nil # e.param
      }.to_json, 500)
    end

    prefix 'api'

    format :json
    default_format :json

    version 'v1', using: :path, vendor: 'piecemaker'
    
    helpers Piecemaker::Helper::Auth
    
    mount ::Piecemaker::Users
    mount ::Piecemaker::EventGroups
    mount ::Piecemaker::Events
    mount ::Piecemaker::System
    

    if ENV['RACK_ENV'].to_sym == :development
      add_swagger_documentation api_version: 'v1'
    end
    
  end
end

