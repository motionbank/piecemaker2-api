require 'spec_helper'

describe "Piecemaker::API System" do
  include Rack::Test::Methods
  def app
    Piecemaker::API
  end

  before(:each) do
    truncate_db
  end


  ##############################################################################
  describe "GET /api/v1/utc_timestamp" do
  ##############################################################################

    #---------------------------------------------------------------------------
    it "returns server timestamp with milliseconds" do
    #---------------------------------------------------------------------------
      get "/api/v1/system/utc_timestamp"
      last_response.status.should == 200
      result = json_string_to_hash(last_response.body)

      result[:utc_timestamp].is_a?(Float).should eq(true)

      # timeout?
      timeout = 10 # sec

      result[:utc_timestamp].should >= (Time.now - timeout).utc.to_f
      result[:utc_timestamp].should < (Time.now).utc.to_f
    end
    #---------------------------------------------------------------------------
  end

end