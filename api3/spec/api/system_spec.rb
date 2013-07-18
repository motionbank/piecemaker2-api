require 'spec_helper'

describe "Piecemaker::API System" do
  include Rack::Test::Methods

  def app
    Piecemaker::API
  end

  before(:all) do
    truncate_db

  end

  it "GET /api/v1/utc_timestamp returns server timestamp with milliseconds" do
    raise
    # get unix timestamp with milliseconds
    # Likes: ``````
    # Returns: time

  end


end

