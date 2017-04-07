require 'rails_helper'

RSpec.describe 'Followers', type: :request do
  let!(:user) { create_user_and_sign_in }
  let(:other_user) { Fabricate(:user) }
  let(:data) { JSON.parse(response.body) if response.body.present? }
  let(:auth_headers) { auth_headers_from_response }

  describe 'a followed user appears in the list of following' do
    before(:each) { user.follow(other_user) }

    it 'appears in the list of followers' do
      get '/v1/following', headers: auth_headers

      expect(response.status).to eq 200
      expect(data['data'].size).to eq 1
      expect(data['data'].first['id']).to eq other_user.id
    end

    it 'does not appear in the list of followers' do
      get '/v1/followers', headers: auth_headers
      expect(response.status).to eq 200
      expect(data['data'].size).to eq 0
    end
  end

  describe 'a following user appears in the list of followers' do
    before(:each) { other_user.follow(user) }

    it 'appears in the list of followers' do
      get '/v1/followers', headers: auth_headers

      expect(response.status).to eq 200
      expect(data['data'].size).to eq 1
      expect(data['data'].first['id']).to eq other_user.id
    end

    it 'does not appear in the list of followers' do
      get '/v1/following', headers: auth_headers
      expect(response.status).to eq 200
      expect(data['data'].size).to eq 0
    end
  end

  it 'followers are paginated' do

  end

  it 'following is paginated' do

  end
end
