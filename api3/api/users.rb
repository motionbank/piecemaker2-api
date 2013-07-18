module Piecemaker

  class Users < Grape::API

    resource 'user' do

      # --------------------------------------------------
      desc "Log in user."
      params do
        requires :email, type: String, desc: "email address"
        requires :password, type: String, desc: "password"
      end 
      post "/login" do
        require "Digest"
        user = User.first(
          :email => params[:email], 
          :password => Digest::SHA1.hexdigest(params[:password]),
          :is_disabled => false)
        if user
          api_access_key = Piecemaker::Helper::API_Access_Key::generate
          user.update(:api_access_key => api_access_key)
          return {:api_access_key => api_access_key}
        else
          error!('Unauthorized', 401)
        end
        
      end

      # --------------------------------------------------
      desc "Log out user."
      post "/logout" do
        _user = authorize!
        _user.update(:api_access_key => nil)
        {:api_access_key => nil}
      end

      # --------------------------------------------------
      desc "Creates new user."
      params do
        requires :name, type: String, desc: "users fullname or whatever"
        requires :email, type: String, desc: "email address"
        optional :is_admin, type: Boolean, desc: "make this user an admin", 
          :default => false
      end 
      post "/" do
        _user = authorize!(:admin_only)

        new_password = Piecemaker::Helper::Password::generate(6)

        user = User.create(
          :name     => params[:name],
          :email    => params[:email],
          :is_admin => params[:is_admin],
          :password => Digest::SHA1.hexdigest(new_password))

        user.password = new_password
      end

      # --------------------------------------------------
      desc "returns currently logged in user"
      get "/me" do
        _user = authorize!
      end

      # --------------------------------------------------
      desc "returns user for id"
      params do
        requires :id, type: Integer, desc: "a user id"
      end
      get "/:id" do
        _user = authorize!
        User.find(:id => params[:id])
      end

      # --------------------------------------------------
      desc "updates user with id"
      params do
        requires :id, type: Integer, desc: "a user id"
        optional :name, type: String, desc: "users fullname or whatever"
        optional :email, type: String, desc: "email address"
        optional :is_admin, type: Boolean, desc: "make this user an admin"
        optional :is_disabled, type: Boolean, desc: "disable this user"
        optional :new_password, type: Boolean, desc: "create new password"
      end
      put "/:id" do
        _user = authorize!(:admin_only)
        user = User.find(:id => params[:id])
        error!('Not found', 404) unless user

        user.update_with_params!(params, :name, :email, :is_admin, :is_disabled)

        new_password = nil
        if params[:new_password]
          new_password = Piecemaker::Helper::Password::generate(6)
          user.password = Digest::SHA1.hexdigest(new_password)
        end

        user.save        
        user.password = new_password if new_password
        return user
      end

      # --------------------------------------------------
      desc "deletes user with id"
      params do
        requires :id, type: Integer, desc: "a user id"
      end
      delete "/:id" do
        _user = authorize!(:admin_only)
        user = User.find(:id => params[:id])
        error!('Not found', 404) unless user

        user.delete
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
