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



CONFIG = YAML.load(IO.read(File.expand_path('../config.yml', __FILE__)))

ENV['RACK_ENV'] ||= "production"
ENV['NEW_RELIC_LICENSE_KEY'] = CONFIG["newrelic_license_key"]
ENV["NEW_RELIC_APP_NAME"] = "Piecemaker API"

DB = Sequel.connect(
  :adapter  => CONFIG[ENV['RACK_ENV'].to_s]["adapter"] || 'postgres', 
  :host     => CONFIG[ENV['RACK_ENV'].to_s]["host"] || 'localhost', 
  :database => CONFIG[ENV['RACK_ENV'].to_s]["database"] || '', 
  :user     => CONFIG[ENV['RACK_ENV'].to_s]["username"] || '', 
  :password => CONFIG[ENV['RACK_ENV'].to_s]["password"] || '',
  :port     => CONFIG[ENV['RACK_ENV'].to_s]["port"] || '5432',
  :max_connections => CONFIG[ENV['RACK_ENV'].to_s]["max_connections"] || 4)

require File.expand_path('../application', __FILE__)