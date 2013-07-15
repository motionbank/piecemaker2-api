require "spec_helper.rb"

describe UsersController::API do

  it 'returns all users' do
    with_api(Piecemaker) do
      get_request(:path => '/v1/users') do |c|
        json = JSON.parse(c.response)
        json[0]["name"].should eq("Matthias")
      end
    end
  end

end