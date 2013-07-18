module Piecemaker

  class Users < Grape::API

    resource 'user' do

      # --------------------------------------------------
      desc "Log in user"
      params do
        requires :email, type: String, desc: "Email address"
        requires :password, type: String, desc: "Password"
      end 
      post "/login" do
        require "Digest"
        user = User.first(
          :email => params[:email], 
          :password => Digest::SHA1.hexdigest(params[:password]))

        if user
          api_access_key = Piecemaker::Helper::API_Access_Key::generate
          user.update(:api_access_key => api_access_key)
          return {:api_access_key => api_access_key}
        else
          error!('Unauthorized', 401)
        end
        
      end

      # --------------------------------------------------
      desc "Log out user"
      post "/logout" do
        _user = authorize!
        _user.update(:api_access_key => nil) ? {:api_access_key => nil} :
          error!('Internal Server Error', 500)
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
