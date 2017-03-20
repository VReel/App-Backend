require 'rails_helper'

RSpec.describe 'Stats', type: :request do
  it 'chiefs can access stats' do
    create_user_and_sign_in('dan@reasonfactory.com')
    get '/v1/stats', headers: auth_headers_from_response
    expect(response.status).to eq 200
  end

  it 'other users can not access stats' do
    create_user_and_sign_in
    get '/v1/stats', headers: auth_headers_from_response
    expect(response.status).to eq 401
  end
end
