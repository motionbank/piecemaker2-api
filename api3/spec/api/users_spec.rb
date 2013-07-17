require 'spec_helper'

describe Piecemaker::API do
  include Rack::Test::Methods

  def app
    Piecemaker::API
  end

  before(:all) do
    @peter = User.make :peter
    @pan = User.make :pan

    @foo = EventGroup.make :alpha, :id => 2
    puts @foo.to_json

  end

  it "/api/v1/users returns all users" do
    get "/api/v1/users.json"
    last_response.status.should == 200
    last_response.body.should == [@peter, @pan].to_json
  end

end

