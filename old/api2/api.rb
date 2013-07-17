require 'grape'
require 'mongoid'

$LOAD_PATH << '.'

# load models
%w{user}.each do |m| 
  require "models/#{m}"
end

module Piecemaker
  class APIv1 < Grape::API

    version 'v1', :using => :path
    format :json
    default_format :json

    # load apis
    %w{users}.each do |a|
      require "api/#{a}"
      mount Kernel.const_get("#{a.capitalize}::API")
    end
    
  end
end