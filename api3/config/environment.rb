require "sequel"
require 'yaml'

require File.expand_path('../../lib/helper', __FILE__)

# @todo move this somewhere else!!
module Sequel
  class Model
    def update_with_params!(params, *attributes)
      attributes.each do |key, value|
        if params.include?(key)
          self[key] = params[key]
        end
      end
    end
  end
end



config = YAML.load(IO.read(File.expand_path('../config.yml', __FILE__)))

ENV['RACK_ENV'] ||= "production"
ENV['NEW_RELIC_LICENSE_KEY'] = config["newrelic_license_key"]
ENV["NEW_RELIC_APP_NAME"] = "Piecemaker API"

DB = Sequel.connect(
  :adapter  => config[ENV['RACK_ENV'].to_s]["adapter"] || 'postgres', 
  :host     => config[ENV['RACK_ENV'].to_s]["host"] || 'localhost', 
  :database => config[ENV['RACK_ENV'].to_s]["database"] || '', 
  :user     => config[ENV['RACK_ENV'].to_s]["username"] || '', 
  :password => config[ENV['RACK_ENV'].to_s]["password"] || '',
  :max_connections => config[ENV['RACK_ENV'].to_s]["max_connections"] || 4)

require File.expand_path('../application', __FILE__)