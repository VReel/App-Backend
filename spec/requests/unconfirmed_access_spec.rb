require 'rails_helper'

RSpec.describe 'Unconfirmed access', type: :request do
  let(:email) { Faker::Internet.email }
  let(:handle) { fake_handle }
  let(:password) { Faker::Internet.password }
  let(:data) { JSON.parse(response.body) if response.body.present? }
  before(:each) { post_user }

  def post_user
    post '/v1/users', params: {
      email: email,
      handle: handle,
      password: password,
      password_confirmation: password
    }
  end

  def post_sign_in
    post '/v1/users/sign_in', params: {
      login: email,
      password: password
    }, xhr: true
  end

  describe 'within 24 hours' do
    it 'can login' do
      post_sign_in
      expect(response.status).to eq 200
    end
  end

  describe 'after 24 hours' do
    before(:each) { Timecop.freeze(Time.current + 25.hours) }
    after(:each) { Timecop.return }

    it 'cannot login' do
      post_sign_in
      expect(response.status).to eq 401
    end

    it 'should error' do
      post_sign_in
      expect(data['errors'].first['detail']).to eq(
        I18n.t('devise_token_auth.sessions.not_confirmed', email: email)
      )
    end
  end
end
