require 'rails_helper'

RSpec.describe 'Registration requests', type: :request do
  let(:email) { Faker::Internet.email }
  let(:handle) { fake_handle }
  let(:data) { JSON.parse(response.body) }

  describe 'Validate non-empty body' do
    before(:each) do
      post '/v1/users', params: {}
    end

    let(:data) { JSON.parse(response.body) }

    it 'request should fail' do
      expect(response.status).to eq 422
    end

    it 'returns error message' do
      expect(data['errors']).to be_present
    end

    it 'user should not have been saved' do
      assert_equal User.count, 0
    end
  end

  describe 'Validate passwords match' do
    def post_user
      post '/v1/users', params: {
        email: email,
        handle: handle,
        password: 'secret123',
        password_confirmation: 'a different password',
        unpermitted_param: '(x_x)'
      }
    end

    it 'request should fail' do
      post_user

      expect(response.status).to eq 422
    end

    it 'should not create a user' do
      expect { post_user }.not_to change { User.count }
    end

    it 'it should return an errors packet with a source record pointing to password_confirmation' do
      post_user

      expect(data['errors'].first['source']['pointer']).to eq '/data/attributes/password-confirmation'
    end
  end

  describe 'Validate email is unique' do
    let!(:user) { Fabricate(:user, email: email) }

    def post_user
      post '/v1/users', params: {
        email: email,
        handle: handle,
        password: 'secret123',
        password_confirmation: 'secret123'
      }
    end

    it 'request should fail' do
      post_user

      expect(response.status).to eq 422
    end

    it 'should not create a user' do
      expect { post_user }.not_to change { User.count }
    end

    it 'it should return an errors packet with a source record pointing to email' do
      post_user

      expect(data['errors'].first['source']['pointer']).to eq '/data/attributes/email'
    end
  end

  describe 'Validate handle is unique' do
    let!(:user) { Fabricate(:user, handle: handle) }

    def post_user
      post '/v1/users', params: {
        email: email,
        handle: handle,
        password: 'secret123',
        password_confirmation: 'secret123',
        unpermitted_param: '(x_x)'
      }
    end

    it 'request should fail' do
      post_user

      expect(response.status).to eq 422
    end

    it 'should not create a user' do
      expect { post_user }.not_to change { User.count }
    end

    it 'it should return an errors packet with a source record pointing to handle' do
      post_user

      expect(data['errors'].first['source']['pointer']).to eq '/data/attributes/handle'
    end
  end

  describe 'A password confirmation is required' do
    def post_user
      post '/v1/users', params: {
        email: email,
        handle: handle,
        password: 'secret123',
        unpermitted_param: '(x_x)'
      }
    end

    it 'request should fail' do
      post_user

      expect(response.status).to eq 422
    end

    it 'should not create a user' do
      expect { post_user }.not_to change { User.count }
    end

    it 'it should return an errors packet with a source record pointing to handle' do
      post_user

      expect(data['errors'].first['source']['pointer']).to eq '/data/attributes/password-confirmation'
    end
  end

  describe 'Multiple validation errors' do
    let!(:user) { Fabricate(:user, handle: handle, email: email) }

    def post_user
      post '/v1/users', params: {
        email: email,
        handle: handle,
        password: 'secret123',
        password_confirmation: 'different',
        unpermitted_param: '(x_x)'
      }
    end

    it 'it should return all validation errors' do
      post_user

      expect(data['errors'].size).to eq 3
    end
  end

  describe 'Successful registration' do
    def post_user
      post '/v1/users', params: {
        email: email,
        handle: fake_handle,
        password: 'secret123',
        password_confirmation: 'secret123',
        unpermitted_param: '(x_x)'
      }
    end

    it 'user should have been created' do
      expect { post_user }.to change { User.count }.by(1)
    end

    it 'only one email was sent' do
      expect { post_user }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    describe 'after post' do
      before(:each) { post_user }

      it 'request should be successful' do
        expect(response.status).to eq 201
      end

      it 'user should not be confirmed' do
        expect(User.last.confirmed_at).to be nil
      end

      it 'new user data should be returned as json' do
        expect(data['data']['attributes']['email']).to be_present
      end

      it 'new user should receive confirmation email' do
        expect(ActionMailer::Base.deliveries.last['to'].to_s).to eq email
      end

      it 'new user password should not be returned' do
        expect(data['data']['attributes']['password']).to be nil
      end
    end
  end
end
