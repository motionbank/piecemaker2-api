class ApiNewRelicInstrumenter < Grape::Middleware::Base
  include NewRelic::Agent::Instrumentation::ControllerInstrumentation
 
  def call_with_newrelic(&block)
    trace_options = {
      :category => :rack,
      :path => "#{route_path}\##{route_method}",
      :request => request
    }
 
    perform_action_with_newrelic_trace(trace_options) do
      result = yield
      MetricFrame.abort_transaction! if result.first == 404 # ignore cascaded calls
      return result
    end
  end
 
  def call(env)
    @env = env
    #if ENV['NEW_RELIC_ID']
    if ENV['ENABLE_NEWRELIC']
      call_with_newrelic do
        super
      end
    else
      super
    end
  end
 
  def env
    @env
  end
 
  def route
    env['api.endpoint'].routes.first
  end
 
  def route_method
    route.route_method.downcase
  end
 
  def route_path
    path = route.route_path.gsub(/^.+:version\/|^\/|:|\(.+\)/, '').tr('/', '-')
    "api.#{route.route_version}.#{path}"
  end
 
end

module Piecemaker
  class API < Grape::API
    use ApiNewRelicInstrumenter

    prefix 'api'

    format :json
    default_format :json

    version 'v1', using: :path, vendor: 'piecemaker'
    
    # rescue from all thrown exceptions,
    # return error code 500 and message with explanation
    rescue_from :all do |e|
      
      # @todo implement logging
      $stderr.puts e if ["development"].include?(ENV['RACK_ENV'])

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
    
  end
end
