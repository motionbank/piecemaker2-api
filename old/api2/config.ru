require './api'
require 'rack/cors'

Mongoid.load!("./config/mongoid.yml")
Mongoid.logger = Logger.new($stdout)

use Rack::Cors do
  allow do
    origins '*'
    resource '*', headers: :any, methods: :get
  end
end

run Piecemaker::APIv1

#run Sinatra::Application
# set :logging, false