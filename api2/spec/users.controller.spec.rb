require "spec_helper.rb"

describe UsersController::API do
  it 'sets the content type' do
    with_api(Piecemaker) do
      get_request({:query => {:callback => 'test'}}) do |c|
        c.response_header['CONTENT_TYPE'].should =~ %r{^application/javascript}
      end
    end
  end
end