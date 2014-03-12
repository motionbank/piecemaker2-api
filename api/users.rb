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
          # create new api_access_key if non exists
          unless @user.api_access_key
            @user.update(:api_access_key => Piecemaker::Helper::API_Access_Key::generate)
          end
          return {:api_access_key => @user.api_access_key}
        else
          error!('Unauthorized', 401)
        end
      end
      

      #_________________________________________________________________________
      ##########################################################################
      desc "Log out user. (logged in user only)"
      #-------------------------------------------------------------------------
      post "/logout" do  #/api/v1/user/logout
      #-------------------------------------------------------------------------
        @_user = authorize!

        # as discussed here: https://github.com/motionbank/piecemaker2-api/issues/74
        # do not delete api_access_key when logging out
        # @_user.update(:api_access_key => nil)
        # {:api_access_key => nil}
        return nil
      end
      

      #_________________________________________________________________________
      ##########################################################################
      desc "Creates new user. (:super_admin_only)"
      #-------------------------------------------------------------------------
      params do
        requires :name, type: String, desc: "users fullname or whatever"
        requires :email, type: String, desc: "email address"
        optional :is_super_admin, type: Boolean, desc: "make this user a super admin", 
          :default => false
      end 
      #-------------------------------------------------------------------------
      post "/" do  #/api/v1/user
      #-------------------------------------------------------------------------
        @_user = authorize! :super_admin_only

        # check if user with this email exists and return appropriate error code
        error!('Duplicate user', 409) if User.first(:email => params[:email])
        
        new_password = Piecemaker::Helper::Password::generate(6)

        @user = User.create(
          :name     => params[:name],
          :email    => params[:email],
          :is_super_admin => params[:is_super_admin],
          :password => Digest::SHA1.hexdigest(new_password))

        # @user.password = new_password
        return {
          :id => @user.id,
          :name => @user.name,
          :email => @user.email,
          :password => new_password,
          :is_super_admin => @user.is_super_admin
        }
      end
      

      #_________________________________________________________________________
      ##########################################################################
      desc "returns currently logged in user (logged in user only)"
      #-------------------------------------------------------------------------
      get "/me" do  #/api/v1/user/me
      #-------------------------------------------------------------------------
        @_user = authorize!
        return {
          :id => @_user.id,
          :name => @_user.name,
          :email => @_user.email,
          :is_super_admin => @_user.is_super_admin
        }
      end
      

      #_________________________________________________________________________
      ##########################################################################
      desc "returns user for id (logged in user only)"
      #-------------------------------------------------------------------------
      params do
        requires :id, type: Integer, desc: "a user id"
      end
      #-------------------------------------------------------------------------
      get "/:id" do  #/api/v1/user/:id
      #-------------------------------------------------------------------------
        @_user = authorize!
        user = User.first(:id => params[:id]) || error!('Not found', 404)
        return {
          :id => user.id,
          :name => user.name,
          :email => user.email,
          :is_super_admin => user.is_super_admin
        }
      end
      

      #_________________________________________________________________________
      ##########################################################################
      desc "updates user with id (:super_admin_only)"
      #-------------------------------------------------------------------------
      params do
        requires :id, type: Integer, desc: "a user id"
        optional :name, type: String, desc: "users fullname or whatever"
        optional :email, type: String, desc: "email address"
        optional :is_super_admin, type: Boolean, desc: "make this user a super admin"
        optional :is_disabled, type: Boolean, desc: "disable this user"
        optional :new_password, type: Boolean, desc: "create new password"
      end
      #-------------------------------------------------------------------------
      put "/:id" do  #/api/v1/user/:id
      #-------------------------------------------------------------------------
        @_user = authorize! :super_admin_only
        @user = User.first(:id => params[:id])
        error!('Not found', 404) unless @user

        @user.update_with_params!(params, 
          :name, :email, :is_super_admin, :is_disabled)

        new_password = nil
        if params[:new_password]
          new_password = Piecemaker::Helper::Password::generate(6)
          @user.password = Digest::SHA1.hexdigest(new_password)
        end

        @user.save        
        # @user.password = new_password if new_password
        if new_password
          return {
            :id => @user.id,
            :name => @user.name,
            :email => @user.email,
            :password => new_password,
            :is_super_admin => @user.is_super_admin
          } 
        else
          return {
            :id => @user.id,
            :name => @user.name,
            :email => @user.email,
            :is_super_admin => @user.is_super_admin
          } 
        end
      end
      

      #_________________________________________________________________________
      ##########################################################################
      desc "deletes user with id (:super_admin_only)"
      #-------------------------------------------------------------------------
      params do
        requires :id, type: Integer, desc: "a user id"
      end
      #-------------------------------------------------------------------------
      delete "/:id" do  #/api/v1/user/:id
      #-------------------------------------------------------------------------
        @_user = authorize! :super_admin_only
        @user = User.first(:id => params[:id])
        error!('Not found', 404) unless @user

        @user.delete
      end


      #_________________________________________________________________________
      ##########################################################################
      desc "returns all event_groups for user with id (:super_admin_only)"
      #-------------------------------------------------------------------------
      params do
        requires :id, type: Integer, desc: "a user id"
      end
      #-------------------------------------------------------------------------
      get "/:id/groups" do  #/api/v1/user/:id/groups
      #-------------------------------------------------------------------------
        @_user = authorize! :super_admin_only
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
      desc "Returns all users. (:super_admin_only)"
      #-------------------------------------------------------------------------
      params do
        optional :count, type: Integer, desc: "number of results"
        optional :max_id, type: Integer, desc: "return results to id"
        optional :since_id, type: Integer, desc: "return results from id"
      end
      #-------------------------------------------------------------------------
      get "/" do  #/api/v1/users
      #-------------------------------------------------------------------------
        authorize! :super_admin_only
        User.a().all || []
      end

    end
  end
end
