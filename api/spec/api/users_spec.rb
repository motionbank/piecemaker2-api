require 'spec_helper'

describe "Piecemaker::API User" do
  include Rack::Test::Methods
  def app
    Piecemaker::API
  end


  ##############################################################################
  describe "(authentication)" do
  ##############################################################################

    before(:all) do
      truncate_db
      
      factory_batch do 
        @peter          = User.make :peter
        @pan            = User.make :pan
        @hans_admin     = User.make :hans_admin
        @klaus_disabled = User.make :klaus_disabled
      end
    end


    ############################################################################
    describe "POST /api/v1/user/login" do
    ############################################################################

      #-------------------------------------------------------------------------
      it "returns new api access token on valid credentials" do
      #-------------------------------------------------------------------------
        post "/api/v1/user/login", 
        :email => @peter.email, :password => @peter.name
        last_response.status.should == 201

        result = json_string_to_hash(last_response.body)
        Piecemaker::Helper::API_Access_Key::makes_sense?(
          result[:api_access_key]).should eq(true)
      end
      #-------------------------------------------------------------------------


      #-------------------------------------------------------------------------
      it "fails for right user but with wrong password" do
      #-------------------------------------------------------------------------
        post "/api/v1/user/login", :email => @peter.email, :password => "wrong"
        last_response.status.should == 401
      end
      #-------------------------------------------------------------------------


      #-------------------------------------------------------------------------
      it "fails for disabled user" do
      #-------------------------------------------------------------------------
        post "/api/v1/user/login", :email => @klaus_disabled.email, 
          :password => @klaus_disabled.name
        last_response.status.should == 401
      end
      #-------------------------------------------------------------------------


      #-------------------------------------------------------------------------
      it "fails when using empty password" do
      #-------------------------------------------------------------------------
        post "/api/v1/user/login", :email => @peter.email, :password => ""
        last_response.status.should == 401
      end
      #-------------------------------------------------------------------------


      #-------------------------------------------------------------------------
      it "fails when using empty email and empty password" do
      #-------------------------------------------------------------------------
        post "/api/v1/user/login", :email => "", :password => ""
        last_response.status.should == 401
      end
      #-------------------------------------------------------------------------


      #-------------------------------------------------------------------------
      it "fails when using empty email and correct password from valid user" do
      #-------------------------------------------------------------------------
        post "/api/v1/user/login", :email => "", :password => @peter.name
        last_response.status.should == 401
      end
      #-------------------------------------------------------------------------


      #-------------------------------------------------------------------------
      it "fails when using empty email and any password string" do
      #-------------------------------------------------------------------------
        post "/api/v1/user/login", :email => "", :password => "random_wrong"
        last_response.status.should == 401
      end
      #-------------------------------------------------------------------------


      #-------------------------------------------------------------------------
      it "fails when not sending password and email is empty" do
      #-------------------------------------------------------------------------
        post "/api/v1/user/login", :email => ""
        last_response.status.should == 400
      end
      #-------------------------------------------------------------------------


      #-------------------------------------------------------------------------
      it "fails when not sending email and password is empty" do
      #-------------------------------------------------------------------------
        post "/api/v1/user/login", :password => ""
        last_response.status.should == 400
      end
      #-------------------------------------------------------------------------


      #-------------------------------------------------------------------------
      it "fails when not sending email and password" do
      #-------------------------------------------------------------------------
        post "/api/v1/user/login"
        last_response.status.should == 400
      end 
      #-------------------------------------------------------------------------
    end


    ############################################################################
    describe "POST /api/v1/user/logout " do
    ############################################################################

      #-------------------------------------------------------------------------
      it "invalidates the current api access token" do
      #-------------------------------------------------------------------------
        # get peters updated api_access_key after login
        @peter = User.first(:id => @peter.id)
        header "X-Access-Key", @peter.api_access_key
        post "/api/v1/user/logout"
        last_response.status.should == 201

        result = json_string_to_hash(last_response.body)
        result.should == {:api_access_key => nil}
      end
      #-------------------------------------------------------------------------


      #-------------------------------------------------------------------------
      it "fails if invalid header key" do
      #-------------------------------------------------------------------------
        header "X-Access-Key", "wrong"
        post "/api/v1/user/logout"
        last_response.status.should == 401
      end
      #-------------------------------------------------------------------------


      #-------------------------------------------------------------------------
      it "fails if empty header key is sent" do
      #-------------------------------------------------------------------------
        header "X-Access-Key", ""
        post "/api/v1/user/logout"
        last_response.status.should == 401

        header "X-Access-Key", nil
        post "/api/v1/user/logout"
        last_response.status.should == 400
      end
      #-------------------------------------------------------------------------
    end
  end


  ##############################################################################
  describe "(others)" do
  ##############################################################################

    before(:each) do
      truncate_db
      
      factory_batch do 
        @peter          = User.make :peter
        @pan            = User.make :pan
        @hans_admin     = User.make :hans_admin
        @klaus_disabled = User.make :klaus_disabled


        @alpha                      = EventGroup.make :alpha

        @pan_has_event_group_alpha  = UserHasEventGroup.make :default,  
                                      :user_id => @pan.id, 
                                      :event_group_id => @alpha.id
      end
    end

    ############################################################################
    describe "POST /api/v1/user " do
    ############################################################################  

      #-------------------------------------------------------------------------
      it "creates new user" do
      #-------------------------------------------------------------------------
        header "X-Access-Key", @hans_admin.api_access_key
        post "/api/v1/user", 
          :name => "Michael",
          :email => "michael@example.com",
          :is_admin => false
        last_response.status.should == 201

        user = json_string_to_hash(last_response.body)

        # ignore password field, because is returned plain/text on creation
        user.delete(:password) 

        @user = User[user[:id]].values
        @user.delete(:password)

        user.should == @user

      end
      #-------------------------------------------------------------------------


      #-------------------------------------------------------------------------
      it "ACL auto-testing" do
      #-------------------------------------------------------------------------
        pending
        # get roles and test against this routes
      end
      #-------------------------------------------------------------------------
    end


    ############################################################################
    describe "GET /api/v1/user/me" do
    ############################################################################  

      #-------------------------------------------------------------------------
      it "returns currently logged in user" do
      #-------------------------------------------------------------------------
        header "X-Access-Key", @peter.api_access_key
        get "/api/v1/user/me"
        last_response.status.should == 200
        json_string_to_hash(last_response.body).should == @peter.values
      end
      #-------------------------------------------------------------------------
    end


    ############################################################################
    describe "GET /api/v1/user/:id" do
    ############################################################################  

      #-------------------------------------------------------------------------
      it "returns user for id" do
      #-------------------------------------------------------------------------
        header "X-Access-Key", @peter.api_access_key
        get "/api/v1/user/#{@pan.id}"
        last_response.status.should == 200
        json_string_to_hash(last_response.body).should == @pan.values
      end
      #-------------------------------------------------------------------------


      #-------------------------------------------------------------------------
      it "ACL auto-testing" do
      #-------------------------------------------------------------------------
        pending
        # get roles and test against this routes
      end
      #-------------------------------------------------------------------------
    end


    ############################################################################
    describe "PUT /api/v1/user/:id" do
    ############################################################################  

      #-------------------------------------------------------------------------
      it "updates user with id" do
      #-------------------------------------------------------------------------
        header "X-Access-Key", @hans_admin.api_access_key
        put "/api/v1/user/#{@pan.id}", 
          :name => "Michael",
          :email => "michael@example.com",
          :is_admin => true,
          :is_disabled => true
        last_response.status.should == 200

        # was put persistant?
        returned_pan = json_string_to_hash(last_response.body)
        returned_pan.should == User.first(:id => returned_pan[:id]).values

        # create new password
        header "X-Access-Key", @hans_admin.api_access_key
        put "/api/v1/user/#{@peter.id}", 
          :new_password => true
        last_response.status.should == 200

        # was put persistant?
        returned_peter = json_string_to_hash(last_response.body)
        returned_peter[:password].should_not == @peter.password
      end
      #-------------------------------------------------------------------------


      #-------------------------------------------------------------------------
      it "ACL auto-testing" do
      #-------------------------------------------------------------------------
        pending
        # get roles and test against this routes
      end
      #-------------------------------------------------------------------------
    end


    ############################################################################
    describe "DELETE /api/v1/user/:id deletes" do
    ############################################################################  

      #-------------------------------------------------------------------------
      it "user with id" do
      #-------------------------------------------------------------------------
        header "X-Access-Key", @hans_admin.api_access_key
        delete "/api/v1/user/#{@pan.id}"
        last_response.status.should == 200
        User.first(:id => @pan.id).should eq(nil)
      end
      #-------------------------------------------------------------------------


      #-------------------------------------------------------------------------
      it "ACL auto-testing" do
      #-------------------------------------------------------------------------
        pending
        # get roles and test against this routes
      end
      #-------------------------------------------------------------------------
    end


    ############################################################################
    describe "GET /api/v1/user/:id/groups" do
    ############################################################################  

      #-------------------------------------------------------------------------
      it "returns all event_groups for user with id" do
      #-------------------------------------------------------------------------
        header "X-Access-Key", @peter.api_access_key
        get "/api/v1/user/#{@pan.id}/groups"
        last_response.status.should == 200
        json_string_to_hash(last_response.body)
          .should == times_to_s([@alpha.values])
      end
      #-------------------------------------------------------------------------


      #-------------------------------------------------------------------------
      it "ACL auto-testing" do
      #-------------------------------------------------------------------------
        pending
        # get roles and test against this routes
      end
      #-------------------------------------------------------------------------
    end


    ############################################################################
    describe "GET /api/v1/users " do
    ############################################################################  

      #-------------------------------------------------------------------------
      it "returns all users" do
      #-------------------------------------------------------------------------
        header "X-Access-Key", @hans_admin.api_access_key
        get "/api/v1/users"
        last_response.status.should == 200
        json_string_to_hash(last_response.body).should =~ [@peter.values, 
          @pan.values, @hans_admin.values, @klaus_disabled.values]
      end
      #-------------------------------------------------------------------------


      #-------------------------------------------------------------------------
      it "ACL auto-testing" do
      #-------------------------------------------------------------------------
        pending
        # get roles and test against this routes
      end
      #-------------------------------------------------------------------------
    end

  end
end

