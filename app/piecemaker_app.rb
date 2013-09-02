module Piecemaker
  class App

    # THIS FILE IS DEPRECATED AND NOT USED ANYMORE
    # KEEP IT FOR REFERENCE
    # WILL BE DELETED SOON

    def initialize
    end

    def self.instance
      puts "Piecemaker::App:instance called! Let mattes know if you read this!!!!"
      @instance ||= Rack::Builder.new do
        api = Piecemaker::API
        run api
      end.to_app
    end

    def call(env)
      Piecemaker::API.call(env)
    end
  end
end


