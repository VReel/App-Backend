require 'rails_helper'

RSpec.describe 'Followers', type: :request do
  let!(:user) { create_user_and_sign_in }
  let(:other_user) { Fabricate(:user) }
  let(:data) { JSON.parse(response.body) if response.body.present? }
  let(:auth_headers) { auth_headers_from_response }

  describe 'a followed user appears in the list of following' do
    before(:each) { user.follow(other_user) }

    it 'appears in the list of following' do
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

    it 'has follows_me: false if user does not follow me' do
      get '/v1/following', headers: auth_headers

      expect(data['data'].first['attributes']['follows_me']).to be false
    end

    it 'has follows_me: true if user follows me' do
      other_user.follow(user)

      get '/v1/following', headers: auth_headers

      expect(data['data'].first['attributes']['follows_me']).to be true
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

    it 'does not appear in the list of following' do
      get '/v1/following', headers: auth_headers
      expect(response.status).to eq 200
      expect(data['data'].size).to eq 0
    end

    it 'has followed_by_me: false if I do not follow that user' do
      get '/v1/followers', headers: auth_headers

      expect(data['data'].first['attributes']['followed_by_me']).to be false
    end

    it 'has followed_by_me: true if I follow that user' do
      user.follow(other_user)

      get '/v1/followers', headers: auth_headers

      expect(data['data'].first['attributes']['followed_by_me']).to be true
    end
  end

  describe 'pagination' do
    let(:item_count) { more_than_a_page_count }
    describe 'followers pagination' do
      before(:each) do
        item_count.times { Fabricate(:user).follow(user) }

        get '/v1/followers', headers: auth_headers
      end

      it 'gets a page of followers' do
        first_page_expectations
      end

      it 'gets the next page of followers' do
        next_page_expectations(total: item_count)
      end
    end

    describe 'following pagination' do
      before(:each) do
        item_count.times { user.follow(Fabricate(:user)) }

        get '/v1/following', headers: auth_headers
      end

      it 'gets a page of followers' do
        first_page_expectations
      end

      it 'gets the next page of followers' do
        next_page_expectations(total: item_count)
      end
    end
  end
end
