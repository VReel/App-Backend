require 'rails_helper'

RSpec.describe 'Authenticated requests', type: :request do
  let(:password) { 'I_liek_ham!' }
  let(:confirmed_user) do
    user = Fabricate(:user, password: password, password_confirmation: password)
    user.skip_confirmation!
    user.save
    user
  end

  let(:data) { JSON.parse(response.body) }

  describe 'auth failure without authentication' do
    before(:each) do
      get '/'
    end

    it 'should fail' do
      expect(response.status).to eq 401
    end

    it 'should an error' do
      expect(data['errors']).to be_present
    end

    it 'should not return auth headers' do
      expect(response.headers['client']).not_to be_present
      expect(response.headers['uid']).not_to be_present
      expect(response.headers['access-token']).not_to be_present
      expect(response.headers['expiry']).not_to be_present
    end
  end

  describe 'success with authentication' do
    before(:each) do
      # Disable batch processing for the purpose of this test.
      DeviseTokenAuth.batch_request_buffer_throttle = 0

      post '/v1/users/sign_in', params: {
        login: confirmed_user.email,
        password: password
      }, xhr: true

      get '/', headers: {
        client: response.headers['client'],
        uid: response.headers['uid'],
        'access-token': response.headers['access-token'],
        'token-type' => 'bearer'
      }
    end

    it 'should succeed' do
      expect(response.status).to eq 200
    end

    it 'should return data' do
      expect(data).to be_present
      expect(data['errors']).to be_nil
    end

    it 'should return auth headers for next request' do
      expect(response.headers['client']).to be_present
      expect(response.headers['uid']).to be_present
      expect(response.headers['access-token']).to be_present
      expect(response.headers['expiry']).to be_present
    end
  end

  describe 'multiple requests success with authentication' do
    before(:each) do
      # Disable batch processing for the purpose of this test.
      DeviseTokenAuth.batch_request_buffer_throttle = 0
      ENV['ACCESS_TOKEN_LIFETIME'] = '0'

      post '/v1/users/sign_in', params: {
        login: confirmed_user.email,
        password: password
      }, xhr: true

      get '/', headers: auth_headers_from_response

      @first_response = response

      get '/', headers: auth_headers_from_response

      @second_response = response
    end

    it 'should succeed' do
      expect(@first_response.status).to eq 200
      expect(@second_response.status).to eq 200
    end

    it 'should return data' do
      expect(data).to be_present
      expect(data['errors']).to be_nil
    end

    it 'should return auth headers for each request' do
      expect(@first_response.headers['client']).to be_present
      expect(@first_response.headers['uid']).to be_present
      expect(@first_response.headers['access-token']).to be_present
      expect(@first_response.headers['expiry']).to be_present

      expect(@second_response.headers['client']).to be_present
      expect(@second_response.headers['uid']).to be_present
      expect(@second_response.headers['access-token']).to be_present
      expect(@second_response.headers['expiry']).to be_present
    end

    # if config.change_headers_on_each_request == true
    it 'should change access-token for each request' do
      expect(@first_response.headers['access-token']).not_to eq @second_response.headers['access-token']
    end

    it 'Subsequent request with stale headers should fail' do
      get '/', headers: {
        client: @first_response.headers['client'],
        uid: @first_response.headers['uid'],
        'access-token': @first_response.headers['access-token'],
        'token-type' => 'bearer'
      }

      expect(response.status).to eq 401
    end
  end

  describe 'multiple requests with ACCESS_TOKEN_LIFETIME set' do
    before(:each) do
      # Disable batch processing for the purpose of this test.
      DeviseTokenAuth.batch_request_buffer_throttle = 0
      ENV['ACCESS_TOKEN_LIFETIME'] = '300' # 5 Minutes

      post '/v1/users/sign_in', params: {
        login: confirmed_user.email,
        password: password
      }, xhr: true

      @auth_headers = auth_headers_from_response

      get '/', headers: @auth_headers

      @first_response = response

      get '/', headers: @auth_headers

      @second_response = response
    end

    it 'should succeed' do
      expect(@first_response.status).to eq 200
      expect(@second_response.status).to eq 200
    end

    it 'should return data' do
      expect(data).to be_present
      expect(data['errors']).to be_nil
    end

    it 'should return auth headers for each request' do
      expect(@first_response.headers['client']).to be_present
      expect(@first_response.headers['uid']).to be_present
      expect(@first_response.headers['access-token']).to be_present
      expect(@first_response.headers['expiry']).to be_present

      expect(@second_response.headers['client']).to be_present
      expect(@second_response.headers['uid']).to be_present
      expect(@second_response.headers['access-token']).to be_present
      expect(@second_response.headers['expiry']).to be_present
    end

    # if config.change_headers_on_each_request == true
    it 'should not change access-token for each request' do
      expect(@first_response.headers['access-token']).to eq @second_response.headers['access-token']
    end

    describe 'Subsequent request with stale headers should fail' do
      before(:each) do
        Timecop.freeze(Time.current + 320)

        get '/', headers: @auth_headers

        @third_response = response

        get '/', headers: @auth_headers

        @fourth_response = response
      end
      after(:each) { Timecop.return }

      it 'request should fail' do
        expect(@fourth_response.status).to eq 401
      end

      it 'should change the access token' do
        expect(@third_response.headers['access-token']).to be_present
         expect(@third_response.headers['access-token']).not_to eq(@auth_headers['access-token'])
      end

      it 'next request with new access token should succeed' do
        get '/', headers: @auth_headers.merge('access-token' => @third_response.headers['access-token'])

        expect(response.status).to eq 200
      end
    end
  end

  describe 'multiple requests in single batch' do
    before(:each) do
      DeviseTokenAuth.batch_request_buffer_throttle = 5.seconds
      ENV['ACCESS_TOKEN_LIFETIME'] = '0'

      post '/v1/users/sign_in', params: {
        login: confirmed_user.email,
        password: password
      }, xhr: true

      @auth_response = response

      get '/', headers: {
        client: @auth_response.headers['client'],
        uid: @auth_response.headers['uid'],
        'access-token': @auth_response.headers['access-token'],
        'token-type' => 'bearer'
      }

      @first_response = response

      get '/', headers: {
        client: @auth_response.headers['client'],
        uid: @auth_response.headers['uid'],
        'access-token': @auth_response.headers['access-token'],
        'token-type' => 'bearer'
      }

      @second_response = response
    end

    it 'should succeed' do
      expect(@first_response.status).to eq 200
      expect(@second_response.status).to eq 200
    end

    it 'should return data' do
      expect(data).to be_present
      expect(data['errors']).to be_nil
    end

    it 'should return auth headers for auth request' do
      expect(@auth_response.headers['client']).to be_present
      expect(@auth_response.headers['uid']).to be_present
      expect(@auth_response.headers['access-token']).to be_present
      expect(@auth_response.headers['expiry']).to be_present
    end

    # Uncomment if config.change_headers_on_each_request = true
    it "should not return auth headers for other requests" do
      expect(@first_response.headers['client']).to be_nil
      expect(@first_response.headers['uid']).to be_nil
      expect(@first_response.headers['access-token']).to be_nil
      expect(@first_response.headers['expiry']).to be_nil

      expect(@first_response.headers['client']).to be_nil
      expect(@first_response.headers['uid']).to be_nil
      expect(@first_response.headers['access-token']).to be_nil
      expect(@first_response.headers['expiry']).to be_nil
    end
  end
end
