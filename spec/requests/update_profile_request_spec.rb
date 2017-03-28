require 'rails_helper'

RSpec.describe 'Update profile requests', type: :request do
  let(:password) { 'I_liek_ham!' }
  let(:confirmed_user) do
    user = Fabricate(:user, password: password, password_confirmation: password)
    user.skip_confirmation!
    user.save
    user
  end
  let(:auth_headers) { response.headers.slice('access-token', 'client', 'uid').merge(client_application_header) }
  let(:name) { Faker::Name.name }
  let(:profile) { Faker::Lorem.sentence }
  let(:data) { JSON.parse(response.body) if response.body.present? }

  before(:each) do
    post '/v1/users/sign_in', params: {
      login: confirmed_user.email,
      password: password
    }, headers: client_application_header
  end

  describe 'Update profile attributes' do
    it 'can update attributes' do
      patch '/v1/users', headers: auth_headers, params: { handle: 'a_new_handle' }
      expect(response.status).to eq 200
      confirmed_user.reload
      expect(confirmed_user.handle).to eq 'a_new_handle'
    end

    it 'can update profile and name' do
      patch '/v1/users', headers: auth_headers, params: {
        profile: profile,
        name: name
      }

      expect(response.status).to eq 200
      confirmed_user.reload

      expect(confirmed_user.profile).to eq profile
      expect(confirmed_user.name).to eq name
    end

    it 'cannot update email' do
      old_email = confirmed_user.email

      patch '/v1/users', headers: auth_headers, params: {
        email: Faker::Internet.email,
        name: name
      }

      confirmed_user.reload

      # Email is unchanged.
      expect(confirmed_user.email).to eq old_email
      # Other fields are changed.
      expect(confirmed_user.name).to eq name
    end

    it 'All attributes are returned' do
      patch '/v1/users', headers: auth_headers, params: {
        profile: profile,
        name: name
      }

      expect(data['data']['attributes']['name']).to be_present
      expect(data['data']['attributes']['profile']).to be_present
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

    it 'Cannot update password without a correct current_password' do
      patch '/v1/users', headers: auth_headers, params: {
        password: 'a_new_password_2',
        password_confirmation: 'a_new_password_2',
        current_password: 'not_the_original_password'
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
