require 'spec_helper'

describe Piecemaker::API do
  include Rack::Test::Methods

  def app
    Piecemaker::API
  end

  before(:all) do
    @peter = User.make :peter
    @pan = User.make :pan
  end

  it "/api/v1/users returns all users" do
    get "/api/v1/users"
    last_response.status.should == 200
    last_response.body.should == [@peter.to_json, @pan.to_json]
  end

end

