module UsersController
  class API < Grape::API

    resource 'users' do
      desc "Return all users"
      get "/" do
        User.all
      end

      get "/:id" do
        User.find(params['id'])
      end

      post "/create" do
        User.create(params['user'])
      end
    end
    
  end
end