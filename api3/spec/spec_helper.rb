require 'rubygems'

ENV["RACK_ENV"] ||= 'test'

require 'rack/test'

require File.expand_path("../../config/environment", __FILE__)

Dir[File.expand_path('../../spec/factories/*.rb', __FILE__)].each do |f|
  require f
end

def truncate_db
  DB.tables.each do |table|
    DB[table].truncate(:cascade => true)
  end
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  
  config.mock_with :rspec
  config.expect_with :rspec

  # run spec with tag 'focus' only (if present) and skip all other tests
  config.filter_run_including :focus => true
  config.run_all_when_everything_filtered = true

  config.before(:all) do 
    # @todo: user must do this via console. removed because it 
    # slows down testing process
    # system "rake db:reset[#{ENV["RACK_ENV"]}]"
    
    
  end

  config.after(:all) do 
    # @todo: do we need this? it slows down testing process ...
    # system "rake db:reset[#{ENV["RACK_ENV"]}]"    
  end

end

