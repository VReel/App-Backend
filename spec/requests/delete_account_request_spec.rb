require 'rails_helper'

RSpec.describe 'Delete account requests', type: :request do
  let(:password) { 'I_liek_ham!' }
  let(:confirmed_user) do
    user = Fabricate(:user, password: password, password_confirmation: password)
    user.skip_confirmation!
    user.save
    user
  end

  let(:data) { JSON.parse(response.body) }

  describe 'failure without authentication' do
    before(:each) do
      delete '/v1/users', headers: client_application_header
    end

    it 'should fail' do
      expect(response.status).to eq 401
    end

    it 'should an error' do
      expect(data['errors']).to be_present
    end

    it 'should not delete the user' do
      expect(User.find_by(email: confirmed_user.email)).to be_present
    end
  end

  describe 'success with authentication' do
    before(:each) do
      post '/v1/users/sign_in', params: {
        login: confirmed_user.email,
        password: password
      }, headers: client_application_header

      delete '/v1/users', headers: auth_headers_from_response
    end

    it 'should succeed' do
      expect(response.status).to eq 204
    end

    it 'should delete the user' do
      expect(User.find_by(email: confirmed_user.email)).not_to be_present
    end
  end
end
