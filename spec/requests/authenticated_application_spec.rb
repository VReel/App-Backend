require 'rails_helper'

RSpec.describe 'Authenticated application requests', type: :request do
  let(:user) { Fabricate(:user) }
  let(:data) { JSON.parse(response.body) }

  describe 'auth failure with no client application header' do
    before(:each) do
      post '/v1/users/sign_in', params: {
        login: user.handle,
        password: user.password
      }
    end

    it 'should fail' do
      expect(response.status).to eq 401
    end

    it 'should have the correct error message' do
      expect(data['errors'].first).to eq('Authorized applications only.')
    end
  end

  describe 'auth success with client application header' do
    before(:each) do
      post '/v1/users/sign_in', params: {
        login: user.handle,
        password: user.password
      }, headers: client_application_header
    end

    it 'should succeed' do
      expect(response.status).to eq 200
    end
  end
end
