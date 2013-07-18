module Piecemaker

  class Users < Grape::API

    resource 'user' do
      require "Digest"

      # --------------------------------------------------
      desc "Log in user"
      params do
        requires :email, type: String, desc: "Email address"
        requires :password, type: String, desc: "Password"
      end 
      post "/login" do
        
        user = User.first(
          :email => params[:email], 
          :password => Digest::SHA1.hexdigest(params[:password]))

        if user
          api_access_key = Piecemaker::Helper::generate_api_access_key
          user.update(:api_access_key => api_access_key)
          return {:api_access_key => api_access_key}
        else
          error!('Unauthorized', 401)
        end
        
      end

      # --------------------------------------------------
      desc "Log out user"
      post "/logout" do
        "login"
      end

    end

    resource 'users' do
      
      # --------------------------------------------------
      desc "Returns all users."
      get "/" do
        User.all || []
      end

    end

  end

end
