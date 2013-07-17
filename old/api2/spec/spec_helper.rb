require 'rubygems'
require 'grape'
require 'mongoid'
require 'factory_girl'
require 'rack/test'

$LOAD_PATH << '.'

ENV["RACK_ENV"] ||= 'test'
Mongoid.load!("config/mongoid.yml")

FactoryGirl.find_definitions

RSpec.configure do |config|
  config.mock_with :rspec
  config.expect_with :rspec

  config.include FactoryGirl::Syntax::Methods
end

