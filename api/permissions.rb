require 'yaml' 

module Piecemaker

  class Permissions < Grape::API

    #===========================================================================
    resource 'permissions' do #======================================================
    #===========================================================================


      #_________________________________________________________________________
      ##########################################################################
      desc "get all available permissions"
      #-------------------------------------------------------------------------
      get "/" do  #/api/v1/permissions
      #-------------------------------------------------------------------------
        # create and update config/permissions.yml with 
        # rake roles:update_permissions_file
        
        return YAML.load(IO.read("config/permissions.yml"))
      end

    end

  end
end