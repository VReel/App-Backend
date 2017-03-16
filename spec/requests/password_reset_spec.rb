require 'rails_helper'

RSpec.describe 'Password reset requests', type: :request do
  let(:password) { Faker::Internet.password }
  let(:user) { Fabricate(:user, password: password, password_confirmation: password) }
  let(:password_reset_path) { ActionMailer::Base.deliveries.last.body.to_s[%r{/v1/users/password/edit[^"]*}] }
  let(:data) { JSON.parse(response.body) }

  describe 'request a password reset by email' do
    describe 'succeeds if we recognises the user email' do
      before(:each) do
        post '/v1/users/password', params: {
          email: user.email
        }, headers: client_application_header
      end

      it 'request is successful' do
        expect(response.status).to eq 200
      end

      it 'sends a password reset email' do
        expect(ActionMailer::Base.deliveries.last['to'].to_s).to eq user.email
      end

      it 'has a password reset link' do
        expect(password_reset_path).to be_present
        expect(ActionMailer::Base.deliveries.last.body).to include('Change my password')
      end
    end

    describe 'fails if we do not recognise the user email' do
      before(:each) do
        post '/v1/users/password', params: {
          email: Faker::Internet.email
        }, headers: client_application_header
      end

      it 'request fails' do
        expect(response.status).to eq 404
      end

      it 'has a correct error response' do
        expect(data['errors']).to be_present
      end
    end
  end

  describe 'click confirm link' do
    before(:each) do
      post '/v1/users/password', params: {
        email: user.email
      }, headers: client_application_header
    end

    let(:mail) { ActionMailer::Base.deliveries.last }
    let(:new_password) do
      mail.body.to_s[/<strong id='new-password'>([^<]*)/]
      Regexp.last_match[1]
    end

    describe 'after click' do
      before(:each) do
        get(password_reset_path)
      end

      it 'request is successful' do
        expect(response.status).to eq 302
      end

      it 'sets a new password' do
        user.reload
        expect(user.valid_password?(password)).to be false
      end

      it 'sends the new password by email' do
        expect(mail['to'].to_s).to eq user.email
        expect(mail['subject'].to_s).to eq 'Your new password'
        expect(new_password).to be_present
      end

      it 'password in email is valid' do
        user.reload
        expect(user.valid_password?(new_password)).to be true
      end

      it 'confirms a user who was not already confirmed' do
        expect(user.confirmed?).to be false
        expect(user.reload.confirmed?).to be true
      end
    end

    it 'redirects the user to the thank you page' do
      expect(get(password_reset_path)).to redirect_to ENV['PASSWORD_RESET_REQUEST_URL']
    end
  end
end
