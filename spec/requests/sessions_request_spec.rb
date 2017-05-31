require 'rails_helper'

RSpec.describe 'Session requests', type: :request do
  let(:password) { 'I_liek_ham!' }
  let(:confirmed_user) do
    user = Fabricate(:user, password: password, password_confirmation: password)
    user.skip_confirmation!
    user.save
    user
  end

  let(:data) { JSON.parse(response.body) if response.body.present? }

  describe 'login with email' do
    before(:each) do
      post '/v1/users/sign_in', params: {
        login: confirmed_user.email,
        password: password
      }, headers: client_application_header
    end

    it 'should succeed' do
      expect(response.status).to eq 200
    end

    it 'should return user data' do
      expect(data['data']['attributes']['email']).to eq confirmed_user.email
    end

    it 'should return auth headers' do
      expect(response.headers['client']).to be_present
      expect(response.headers['uid']).to be_present
      expect(response.headers['access-token']).to be_present
      expect(response.headers['expiry']).to be_present
    end
  end

  describe 'login with handle' do
    before(:each) do
      post '/v1/users/sign_in', params: {
        login: confirmed_user.handle,
        password: password
      }, headers: client_application_header
    end

    it 'should succeed' do
      expect(response.status).to eq 200
    end

    it 'should return user data' do
      expect(data['data']['attributes']['email']).to eq confirmed_user.email
    end

    it 'should return auth headers' do
      expect(response.headers['client']).to be_present
      expect(response.headers['uid']).to be_present
      expect(response.headers['access-token']).to be_present
      expect(response.headers['expiry']).to be_present
    end
  end

  describe 'login failure' do
    before(:each) do
      post '/v1/users/sign_in', params: {
        login: confirmed_user.email,
        password: 'some other password'
      }, headers: client_application_header
    end

    it 'should fail' do
      expect(response.status).to eq 401
    end

    it 'should an error' do
      expect(data['errors'].first['detail']).to eq I18n.t('devise_token_auth.sessions.bad_credentials')
    end

    it 'should not return auth headers' do
      expect(response.headers['client']).not_to be_present
      expect(response.headers['uid']).not_to be_present
      expect(response.headers['access-token']).not_to be_present
      expect(response.headers['expiry']).not_to be_present
    end
  end

  describe 'login with player_id' do
    let(:player_id) { SecureRandom.uuid }

    before(:each) do
      post '/v1/users/sign_in', params: {
        login: confirmed_user.email,
        password: password,
        player_id: player_id,
      }, headers: client_application_header
    end

    it 'should succeed' do
      expect(response.status).to eq 200
    end

    it 'should create a device' do
      expect(confirmed_user.reload.devices.count).to eq 1
    end

    it 'the device should belong to the user and have the player_id' do
      expect(confirmed_user.reload.devices.first.player_id).to eq player_id
    end
  end

  describe 'logout' do
    before(:each) do
      post '/v1/users/sign_in', params: {
        login: confirmed_user.email,
        password: password
      }, headers: client_application_header

      @auth_response = response

      delete '/v1/users/sign_out', headers: {
        client: @auth_response.headers['client'],
        uid: @auth_response.headers['uid'],
        'access-token': @auth_response.headers['access-token'],
        'token-type' => 'bearer'
      }.merge(client_application_header)
    end

    it 'should succeed' do
      expect(response.status).to eq 204
    end

    it 'a further request with headers should fail' do
      get '/', headers: {
        client: @auth_response.headers['client'],
        uid: @auth_response.headers['uid'],
        'access-token': @auth_response.headers['access-token'],
        'token-type' => 'bearer'
      }.merge(client_application_header)
      expect(response.status).to eq 401
    end
  end

  describe 'failed logout' do
    it 'should fail if no session' do
      delete '/v1/users/sign_out', xhr: true
      expect(response.status).to eq 401
    end
  end
end
