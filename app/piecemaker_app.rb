module Piecemaker
  class App
    # include NewRelic::Agent::Instrumentation::ControllerInstrumentation

    def initialize
    end


    def self.instance
      puts "Piecemaker::App:instance called! Let mattes know if you read this!!!!"
      @instance ||= Rack::Builder.new do
        api = Piecemaker::API
        run api
      end.to_app
    end

    # def env
    #   @env
    # end
    
    # def route
    #   env['api.endpoint'].routes.first
    # end
    
    # def route_method
    #   route.route_method.downcase
    # end
    
    # def route_path
    #   path = route.route_path.gsub(/^.+:version\/|^\/|:|\(.+\)/, '').tr('/', '-')
    #   "api.#{route.route_version}.#{path}"
    # end

    # def call_with_newrelic(&block)
    #   trace_options = {
    #     :category => :rack,
    #     :path => "#{route_path}\##{route_method}",
    #     :request => request
    #   }
    
    #   perform_action_with_newrelic_trace(trace_options) do
    #     result = yield
    #     MetricFrame.abort_transaction! if result.first == 404 # ignore cascaded calls
    #     result
    #   end
    # end


    def call(env)
      # puts "call".inspect
      # @env = env

      # if ENV['ENABLE_NEWRELIC']
      #  call_with_newrelic do
      #    Piecemaker::API.call(env)
      #    super
      #  end
      #else
        Piecemaker::API.call(env)
      #end
    end
  end
end


