require 'spec_helper'
require 'api/users'
require 'models/user'

describe Users::API do
  include Rack::Test::Methods

  def app
    Users::API
  end

  it "/ returns all users" do
    get "/users"
    last_response.status.should == 200
    # last_response.body.should == { :ping => "pong" }.to_json
    last_response.body.should == "15870"
  end

end