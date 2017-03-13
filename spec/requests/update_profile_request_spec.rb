require 'rails_helper'

RSpec.describe 'Update profile requests', type: :request do
  let(:password) { 'I_liek_ham!' }
  let(:confirmed_user) do
    user = Fabricate(:user, password: password, password_confirmation: password)
    user.skip_confirmation!
    user.save
    user
  end
  let(:auth_headers) { response.headers.slice('access-token', 'client', 'uid') }
  let(:data) { JSON.parse(response.body) if response.body.present? }

  before(:each) do
    post '/v1/users/sign_in', params: {
      login: confirmed_user.email,
      password: password
    }, xhr: true
  end

  describe 'Update profile attributes' do
    it 'can update attributes' do
      patch '/v1/users', headers: auth_headers, params: { handle: 'a_new_handle' }
      expect(response.status).to eq 200
      confirmed_user.reload
      expect(confirmed_user.handle).to eq 'a_new_handle'
    end
  end

  describe 'Update password' do
    it 'Cannot update password without a confirmation' do
      patch '/v1/users', headers: auth_headers, params: {
        password: 'a_new_password',
        current_password: password
      }
      expect(response.status).to eq 422
      confirmed_user.reload
      expect(confirmed_user.valid_password?('a_new_password')).to be false
    end

    it 'Cannot update password without a current_password' do
      patch '/v1/users', headers: auth_headers, params: {
        password: 'a_new_password_2',
        password_confirmation: 'a_new_password_2'
      }
      expect(response.status).to eq 422
      confirmed_user.reload
      expect(confirmed_user.valid_password?('a_new_password_2')).to be false
    end

    it 'Can update password with a confirmation and a current password' do
      patch '/v1/users', headers: auth_headers, params: {
        password: 'a_new_password_3',
        password_confirmation: 'a_new_password_3',
        current_password: password
      }
      expect(response.status).to eq 200
      confirmed_user.reload
      expect(confirmed_user.valid_password?('a_new_password_3')).to be true
    end
  end
end
