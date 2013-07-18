module Piecemaker

  class System < Grape::API

    resource 'system' do

      desc "get unix timestamp with milliseconds"
      get "/utc_timestamp" do
        
      end

    end

  end
end