module Users
  class API < Grape::API

    resource 'users' do

      desc "Return all users"
      get "/" do
        # User.all
        # User.create(name: "Harald")
        User.count
      end

      get "/:id" do
        {"a" => 3}
      end

      post "/create" do
        {"a" => 4}
      end

    end

  end
end