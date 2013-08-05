module Piecemaker
  class App

    def initialize
    end


    def self.instance
      @instance ||= Rack::Builder.new do
        api = Piecemaker::API

        run api
      end.to_app
    end

    def call(env)
      # api
      response = Piecemaker::API.call(env)
    end
  end
end


