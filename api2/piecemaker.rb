#!/usr/bin/env ruby

# curl http://localhost:9080/v1/users

require 'rubygems'
require 'goliath'
require 'grape'
require 'em-synchrony/activerecord'
require 'yajl' if RUBY_PLATFORM != 'java'
# require 'rack/cors'
require 'pathname'

# require models ...
Dir["models/*.rb"].each do |model|
  require Pathname.new(model).expand_path
end

class PiecemakerGrape < Grape::API
  version 'v1', :using => :path
  format :json
  default_format :json

  # use Rack::Cors do
  #   allow do
  #     origins '*'
  #     resource '*', headers: :any, methods: :get
  #   end
  # end

  #http_basic do |username, password|
    # verify user's password here
  #  { 'test' => 'password1' }[username] == password
  #end

  # require and mount controllers ...
  Dir["controllers/*.rb"].each do |controller|
    controller_path = Pathname.new(controller).expand_path
    controller_name = controller_path.basename.to_s
      .gsub(controller_path.extname, '').capitalize
    require controller_path
    module_controller = Kernel.const_get("#{controller_name}Controller")
    mount module_controller::API
    # puts module_controller::API::routes
  end 
end

class Piecemaker < Goliath::API
  def response(env)
    PiecemakerGrape.call(env)
  end
end