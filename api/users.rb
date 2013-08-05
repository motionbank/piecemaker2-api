require "digest"

module Piecemaker

  class Users < Grape::API

    #===========================================================================
    resource 'user' do
    #===========================================================================


      #_________________________________________________________________________
      ##########################################################################
      desc "Log in user."
      #-------------------------------------------------------------------------
      params do
        requires :email, type: String, desc: "email address"
        requires :password, type: String, desc: "password"
      end 
      #-------------------------------------------------------------------------
      post "/login" do  #/api/v1/user/login
      #-------------------------------------------------------------------------
        @user = User.first(
          :email => params[:email], 
          :password => Digest::SHA1.hexdigest(params[:password]),
          :is_disabled => false)
        if @user
          api_access_key = Piecemaker::Helper::API_Access_Key::generate
          @user.update(:api_access_key => api_access_key)
          return {:api_access_key => api_access_key}
        else
          error!('Unauthorized', 401)
        end
      end
      

      #_________________________________________________________________________
      ##########################################################################
      desc "Log out user."
      #-------------------------------------------------------------------------
      post "/logout" do  #/api/v1/user/logout
      #-------------------------------------------------------------------------
        @_user = authorize!
        @_user.update(:api_access_key => nil)
        {:api_access_key => nil}
      end
      

      #_________________________________________________________________________
      ##########################################################################
      desc "Creates new user."
      #-------------------------------------------------------------------------
      params do
        requires :name, type: String, desc: "users fullname or whatever"
        requires :email, type: String, desc: "email address"
        optional :is_admin, type: Boolean, desc: "make this user an admin", 
          :default => false
      end 
      #-------------------------------------------------------------------------
      post "/" do  #/api/v1/user
      #-------------------------------------------------------------------------
        @_user = authorize!(:admin_only)

        new_password = Piecemaker::Helper::Password::generate(6)

        @user = User.create(
          :name     => params[:name],
          :email    => params[:email],
          :is_admin => params[:is_admin],
          :password => Digest::SHA1.hexdigest(new_password))

        @user.password = new_password
        return @user
      end
      

      #_________________________________________________________________________
      ##########################################################################
      desc "returns currently logged in user"
      #-------------------------------------------------------------------------
      get "/me" do  #/api/v1/user/me
      #-------------------------------------------------------------------------
        @_user = authorize!
      end
      

      #_________________________________________________________________________
      ##########################################################################
      desc "returns user for id"
      #-------------------------------------------------------------------------
      params do
        requires :id, type: Integer, desc: "a user id"
      end
      #-------------------------------------------------------------------------
      get "/:id" do  #/api/v1/user/:id
      #-------------------------------------------------------------------------
        @_user = authorize!
        User.first(:id => params[:id]) || error!('Not found', 404)
      end
      

      #_________________________________________________________________________
      ##########################################################################
      desc "updates user with id"
      #-------------------------------------------------------------------------
      params do
        requires :id, type: Integer, desc: "a user id"
        optional :name, type: String, desc: "users fullname or whatever"
        optional :email, type: String, desc: "email address"
        optional :is_admin, type: Boolean, desc: "make this user an admin"
        optional :is_disabled, type: Boolean, desc: "disable this user"
        optional :new_password, type: Boolean, desc: "create new password"
      end
      #-------------------------------------------------------------------------
      put "/:id" do  #/api/v1/user/:id
      #-------------------------------------------------------------------------
        @_user = authorize!(:admin_only)
        @user = User.first(:id => params[:id])
        error!('Not found', 404) unless @user

        @user.update_with_params!(params, 
          :name, :email, :is_admin, :is_disabled)

        new_password = nil
        if params[:new_password]
          new_password = Piecemaker::Helper::Password::generate(6)
          @user.password = Digest::SHA1.hexdigest(new_password)
        end

        @user.save        
        @user.password = new_password if new_password
        return @user
      end
      

      #_________________________________________________________________________
      ##########################################################################
      desc "deletes user with id"
      #-------------------------------------------------------------------------
      params do
        requires :id, type: Integer, desc: "a user id"
      end
      #-------------------------------------------------------------------------
      delete "/:id" do  #/api/v1/user/:id
      #-------------------------------------------------------------------------
        @_user = authorize!(:admin_only)
        @user = User.first(:id => params[:id])
        error!('Not found', 404) unless @user

        @user.delete
      end


      #_________________________________________________________________________
      ##########################################################################
      desc "returns all event_groups for user with id"
      #-------------------------------------------------------------------------
      params do
        requires :id, type: Integer, desc: "a user id"
      end
      #-------------------------------------------------------------------------
      get "/:id/groups" do  #/api/v1/user/:id/groups
      #-------------------------------------------------------------------------
        @_user = authorize!
        @user = User.first(:id => params[:id])
        error!('Not found', 404) unless @user
        
        @user.event_groups
      end

    end



    #===========================================================================
    resource 'users' do
    #===========================================================================
      

      #_________________________________________________________________________
      ##########################################################################
      desc "Returns all users."
      #-------------------------------------------------------------------------
      get "/" do  #/api/v1/users
      #-------------------------------------------------------------------------
        authorize! :admin_only
        User.all || []
      end

    end
  end
end
