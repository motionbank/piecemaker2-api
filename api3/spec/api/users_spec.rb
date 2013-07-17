require 'spec_helper'

describe Piecemaker::API do
  include Rack::Test::Methods

  def app
    Piecemaker::API
  end

  it "/api/v1/users returns all users" do
    user1 = User.make
    get "/api/v1/users"
    last_response.status.should == 200
    last_response.body.should == { :id => 1, :name => "peter" }.to_json
  end

end

