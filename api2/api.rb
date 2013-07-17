require 'grape'
require 'mongoid'

require './models/user'

module Piecemaker
  class APIv1 < Grape::API

    version 'v1', :using => :path
    format :json
    default_format :json

    resource 'users' do
      desc "Return all users"
      get "/" do
        # User.all
        # User.create(name: "Harald")
        User.count
        
      end

      get "/:id" do
        {"a" => 3}
      end

      post "/create" do
        {"a" => 4}
      end
    end
    
  end
end