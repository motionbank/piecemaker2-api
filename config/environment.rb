require "sequel"
require 'yaml'
require File.expand_path('../../lib/helper', __FILE__)


if ENV['ON_HEROKU']
  CONFIG = Hash.new
else
  CONFIG = YAML.load(IO.read(File.expand_path('../config.yml', __FILE__)))
  ENV['ENABLE_NEWRELIC'] = CONFIG["enable_newrelic"].to_s
  ENV['NEWRELIC_LICENSE_KEY'] = CONFIG["newrelic_license_key"]

  ENV['NEWRELIC_MONITOR'] = CONFIG[ENV['RACK_ENV'].to_s]["newrelic_monitor"].to_s
  ENV['NEWRELIC_DEVELOPER'] = CONFIG[ENV['RACK_ENV'].to_s]["newrelic_developer"].to_s
end

ENV['RACK_ENV'] ||= "production"
ENV['ENABLE_NEWRELIC'] ||= 0
ENV['NEWRELIC_LICENSE_KEY'] ||= nil

ENV['NEWRELIC_MONITOR'] = 'false' if ENV['NEWRELIC_MONITOR'].nil?
ENV['NEWRELIC_DEVELOPER'] = 'false' if ENV['NEWRELIC_DEVELOPER'].nil?


ENV["NEWRELIC_APP_NAME"] = "Piecemaker API"


begin
  if ENV['ON_HEROKU']
    DB = Sequel.connect( ENV['DATABASE_URL'] )
  else
    DB = Sequel.connect(
      :test => true, #test that a valid database connection can be made
      :adapter  => CONFIG[ENV['RACK_ENV'].to_s]["adapter"] || 'postgres', 
      :host     => CONFIG[ENV['RACK_ENV'].to_s]["host"] || 'localhost', 
      :database => CONFIG[ENV['RACK_ENV'].to_s]["database"] || '', 
      :user     => CONFIG[ENV['RACK_ENV'].to_s]["username"] || '', 
      :password => CONFIG[ENV['RACK_ENV'].to_s]["password"] || '',
      :port     => CONFIG[ENV['RACK_ENV'].to_s]["port"] || '5432',
      :max_connections => CONFIG[ENV['RACK_ENV'].to_s]["max_connections"] || 4)
  end
rescue=>ex
  puts ex.message
  exit 77
end


require File.expand_path('../application', __FILE__)


