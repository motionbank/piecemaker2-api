require 'spec_helper'
require "yaml"

describe "Piecemaker::API Permission" do
  include Rack::Test::Methods
  def app
    Piecemaker::API
  end

  before(:each) do
    truncate_db
    @frank_super_admin    = User.make :frank_super_admin
  end


  ##############################################################################
  describe "GET /api/v1/permissions", :focus do
  ##############################################################################

    #---------------------------------------------------------------------------
    it "returns all available permissions" do
    #---------------------------------------------------------------------------
      header "X-Access-Key", @frank_super_admin.api_access_key
      get "/api/v1/permissions"
      last_response.status.should == 200
      result = json_string_to_hash(last_response.body)

      entities = YAML.load(IO.read("config/permissions.yml"))
      result.should == entities
    end
    #---------------------------------------------------------------------------
  end
end