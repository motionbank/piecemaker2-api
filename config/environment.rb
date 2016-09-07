require "sequel"
require 'yaml'
require File.expand_path('../../lib/helper', __FILE__)
require 'logger'

# set up logger
if not ENV["ON_HEROKU"] and ["production"].include?(ENV['RACK_ENV'])
  $logger = Logger.new(File.expand_path('../../log/api.log', __FILE__), 'monthly')
else
  # development and test
  $logger = Logger.new(STDOUT)
end

$logger = Logger.new(STDOUT) if ENV["ON_HEROKU"] # overwrite for heroku

if ["production", "test"].include?(ENV['RACK_ENV'])
  $logger.level = Logger::WARN
else 
  # development
  $logger.level = Logger::DEBUG
end

# setup logger format
original_formatter = Logger::Formatter.new
$logger.formatter = proc { |severity, datetime, progname, msg|
  if msg.is_a? Exception
    exception = msg
    msg = "\n\n#{exception.class} (#{exception.message}):\n    " +
          exception.backtrace.join("\n    ") +
          "\n\n"
    original_formatter.call(severity, datetime, progname, msg)
  else
    original_formatter.call(severity, datetime, progname, msg.dump)
  end
}



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
rescue => ex
  $logger.fatal(ex.message) 
  exit 77
end


require File.expand_path('../application', __FILE__)


