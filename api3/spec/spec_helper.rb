require 'rubygems'

ENV["RACK_ENV"] ||= 'test'

require 'rack/test'

require File.expand_path("../../config/environment", __FILE__)

Dir[File.expand_path('../../spec/factories/*.rb', __FILE__)].each do |f|
  require f
end

RSpec.configure do |config|
  config.mock_with :rspec
  config.expect_with :rspec

  config.before(:all) do 
    # empty database
    DB.tables.each do |table|
      DB[table].truncate
    end
    
  end

  config.after(:all) do 
    # empty database
    DB.tables.each do |table|
      DB[table].truncate
    end
    
  end

end

