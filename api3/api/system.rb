module Piecemaker

  class System < Grape::API

    #===========================================================================
    resource 'system' do #======================================================
    #===========================================================================


      #_________________________________________________________________________
      ##########################################################################
      desc "get unix timestamp with milliseconds"
      #-------------------------------------------------------------------------
      get "/utc_timestamp" do  #/api/v1/system/utc_timestamp
      #-------------------------------------------------------------------------
        return {
          :utc_timestamp => Time.now.utc.to_f
        }
      end

    end

  end
end