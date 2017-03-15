require 'rails_helper'

RSpec.describe 'Email confirmation requests', type: :request do
  let(:email) { Faker::Internet.email }
  let(:handle) { fake_handle }
  let(:confirmation_path) { ActionMailer::Base.deliveries.last.body.to_s[%r{/v1/users/confirmation[^"]*}] }
  let(:user) { User.find_by(email: email) }

  def post_user
    post '/v1/users', params: {
      email: email,
      handle: handle,
      password: 'secret123',
      password_confirmation: 'secret123'
    }, headers: client_application_header
  end

  describe 'confirmation email' do
    before(:each) { post_user }

    it 'is sent' do
      expect(ActionMailer::Base.deliveries.last['to'].to_s).to eq email
    end

    it 'has confirmation link' do
      expect(confirmation_path).to be_present
      expect(ActionMailer::Base.deliveries.last.body).to include('Confirm my account')
    end

    it 'confirms the user when the confirmation link is clicked' do
      expect do
        get confirmation_path
      end.to change {
        user.reload
        user.confirmed?
      }.from(false).to(true)
    end

    it 'redirects the user to the redirect URL' do
      expect(get(confirmation_path)).to redirect_to ENV['CONFIRM_SUCCESS_URL']
    end
  end

  describe 'when the confirmation has expired' do
  end

  describe 'resend confirmation email' do
    before(:each) { post_user }

    def request_confirmation_email
      post '/v1/users/confirmation', params: {
        email: email
      }, headers: client_application_header
    end

    def request_confirmation_email_invalid
      post '/v1/users/confirmation', params: {
        email: Faker::Internet.email
      }, headers: client_application_header
    end

    it 'will resend a confirmation email for a valid email' do
      expect do
        request_confirmation_email
      end.to change { ActionMailer::Base.deliveries.size }.by(1)
    end

    it 'will not send a confirmation email for a valid email' do
      expect do
        request_confirmation_email_invalid
      end.not_to change { ActionMailer::Base.deliveries.size }
    end
  end
end
