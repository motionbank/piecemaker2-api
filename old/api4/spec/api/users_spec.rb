require 'spec_helper'

describe Piecemaker::API do
  include Rack::Test::Methods

  def app
    Piecemaker::API
  end

  it "/api/v1/users returns all users" do
    get "/api/v1/users"
    last_response.status.should == 200
    last_response.body.should == { :a => "b" }.to_json
  end

end

