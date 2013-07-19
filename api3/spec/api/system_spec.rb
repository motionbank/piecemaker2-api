require 'spec_helper'

describe "Piecemaker::API System" do
  include Rack::Test::Methods
  def app
    Piecemaker::API
  end

  before(:each) do
    truncate_db
  end

  # =======================================================================
  describe "GET /api/v1/utc_timestamp" do

    # ------------------------------------------------
    it "returns server timestamp with milliseconds" do
      pending
    end
  end

end