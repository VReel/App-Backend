require 'rails_helper'

RSpec.describe 'Delete account requests', type: :request do
  let(:password) { 'I_liek_ham!' }
  let(:user) { Fabricate(:user, password: password, password_confirmation: password) }
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
      expect(User.find_by(email: user.email)).to be_present
    end
  end

  describe 'success with authentication' do
    before(:each) do
      post '/v1/users/sign_in', params: {
        login: user.email,
        password: password
      }, headers: client_application_header

      delete '/v1/users', headers: auth_headers_from_response
    end

    it 'should succeed' do
      expect(response.status).to eq 204
    end

    it 'should delete the user' do
      expect(User.find_by(email: user.email)).not_to be_present
    end
  end

  describe "delete user's assets and posts" do
    before(:each) do
      post '/v1/users/sign_in', params: {
        login: user.email,
        password: password
      }, headers: client_application_header
    end

    it 'deletes the posts' do
      post '/v1/users/sign_in', params: {
        login: user.email,
        password: password
      }, headers: client_application_header

      25.times { Fabricate(:post, user: user) }

      expect do
        delete '/v1/users', headers: auth_headers_from_response
      end.to change { Post.where(user_id: user.id).count }.from(25).to(0)
    end

    it 'deletes the S3 folder' do
      expect_any_instance_of(S3DeletionService).to receive(:delete).with(user.unique_id)

      delete '/v1/users', headers: auth_headers_from_response
    end
  end
end
