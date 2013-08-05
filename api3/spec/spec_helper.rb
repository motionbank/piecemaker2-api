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

def factory_batch(&block)
  factories = %w(User Event EventGroup EventField UserHasEventGroup)
  factories.each do |factory|
    Object.const_get(factory).unrestrict_primary_key
  end

  block.call

  factories.each do |factory|
    Object.const_get(factory).restrict_primary_key
  end
end



# deprecated, use json_string_to_hash instead
def json_parse(string)
  json_string_to_hash(string)
  # @todo dont parse if empty string or nil
  # if string.class == String && string == "null"
  #   nil
  # else
  #   JSON.parse(string, {:symbolize_names => true})
  # end
end

def times_to_s(obj)

  if obj.is_a? Hash
    
    if obj.key? :created_at
      obj[:created_at] = obj[:created_at].to_s
    elsif obj.key? "created_at"
      obj["created_at"] = obj["created_at"].to_s
    end

  elsif obj.is_a? Array
    obj.each do |oneobj|
      oneobj = times_to_s(oneobj)
    end
  end
  
  return obj
end

def json_string_to_hash(json)
  return nil if json.class == String && json == "null"
  JSON.parse(json, {:symbolize_names => true})
end

module Sequel
  class Dataset
    # convert dataset values to Hash
    # @todo consider looping over all dataset elements and calling
    # this sequel json plugin on them. however, this works as well
    # but its not very nice.
    def all_values
      # @todo haha ... this is bad! 
      # converting to_json and then parsing it again!
      # there must be a better way!!!!
      json_string_to_hash(self.to_json)
    end
  end
end




# def set_api_access_key_for_user(user) # user id or user object
#   if user.is_a? Integer
#     user = User.first(:id => user)
#   end
#   api_access_key = Piecemaker::Helper::API_Access_Key::generate
#   user.update(:api_access_key => api_access_key)
#   api_access_key
# end
# 
# def request_with_api_access_key_from_user(user)
#   api_access_key = set_api_access_key_for_user(@peter)
#   header "X-Access-Key", api_access_key
# end


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

