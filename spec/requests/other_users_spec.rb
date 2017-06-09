require 'rails_helper'

RSpec.describe 'Other users', type: :request do
  let!(:user) { create_user_and_sign_in }
  let(:gandalf) { Fabricate(:user) }
  let(:data) { JSON.parse(response.body) }
  let(:next_response_data) { JSON.parse(response.body) }
  let(:total_records) { more_than_a_page_count }
  let(:auth_headers) { auth_headers_from_response }

  describe 'user full details' do
    before(:each) do
      get "/v1/users/#{gandalf.id}", headers: auth_headers
    end

    it 'can get user details' do
      expect(response.status).to eq 200
      expect(data['data']['id']).to eq gandalf.id
    end

    it 'shows if I follow the user' do
      expect(data['data']['attributes']['followed_by_me']).to be false

      user.follow(gandalf)

      get "/v1/users/#{gandalf.id}", headers: auth_headers

      expect(next_response_data['data']['attributes']['followed_by_me']).to be true
    end

    it 'shows if the user follows me' do
      expect(data['data']['attributes']['follows_me']).to be false

      gandalf.follow(user)

      get "/v1/users/#{gandalf.id}", headers: auth_headers

      expect(next_response_data['data']['attributes']['follows_me']).to be true
    end
  end

  describe 'list posts' do
    before(:each) do
      total_records.times { fabricate_post_for(gandalf) }

      get "/v1/users/#{gandalf.id}/posts", headers: auth_headers
    end

    it 'gets the most recent post first' do
      expect(data['data'].first['id']).to eq Post.all.order('created_at desc').first.id
    end

    it 'gets a page of posts' do
      first_page_expectations
    end

    it 'gets the next page of posts' do
      next_page_expectations(total: total_records)
    end
  end

  describe 'list liked posts' do
    before(:each) do
      total_records.times do
        gandalf.like(fabricate_post_for(Fabricate(:user)))
      end

      get "/v1/users/#{gandalf.id}/likes", headers: auth_headers
    end

    it 'can get a page of posts liked by a user' do
      first_page_expectations
    end

    it 'can get the next page' do
      next_page_expectations(total: total_records)
    end
  end

  describe 'followers' do
    describe 'pagination' do
      before(:each) do
        total_records.times do
          Fabricate(:user).follow(gandalf)
        end

        get "/v1/users/#{gandalf.id}/followers", headers: auth_headers
      end

      it 'can get a page of followers' do
        first_page_expectations
      end

      it 'can get the next page' do
        next_page_expectations(total: total_records)
      end
    end

    describe 'follows_me and followed_by_me' do
      let(:saruman) { Fabricate(:user) }
      before(:each) do
        saruman.follow(gandalf)
      end

      it 'has follows_me: false if the user does not follow me' do
        get "/v1/users/#{gandalf.id}/followers", headers: auth_headers

        expect(data['data'].first['attributes']['follows_me']).to be false
      end

      it 'has follows_me: true if the user does follow me' do
        saruman.follow(user)

        get "/v1/users/#{gandalf.id}/followers", headers: auth_headers

        expect(data['data'].first['id']).to eq saruman.id
        expect(data['data'].first['attributes']['follows_me']).to be true
      end

      it 'has followed_by_me: false if I do not follow the user' do
        get "/v1/users/#{gandalf.id}/followers", headers: auth_headers

        expect(data['data'].first['attributes']['followed_by_me']).to be false
      end

      it 'has followed_by_me: true if I do follow the user' do
        user.follow(saruman)

        get "/v1/users/#{gandalf.id}/followers", headers: auth_headers

        expect(data['data'].first['attributes']['followed_by_me']).to be true
      end
    end
  end

  describe 'following' do
    describe 'pagination' do
      before(:each) do
        total_records.times do
          gandalf.follow(Fabricate(:user))
        end

        get "/v1/users/#{gandalf.id}/following", headers: auth_headers
      end

      it 'can get a page of followed users' do
        first_page_expectations
      end

      it 'can get the next page' do
        next_page_expectations(total: total_records)
      end
    end

    describe 'follows_me and followed_by_me' do
      let(:saruman) { Fabricate(:user) }
      before(:each) do
        gandalf.follow(saruman)
      end

      it 'has follows_me: false if the user does not follow me' do
        get "/v1/users/#{gandalf.id}/following", headers: auth_headers

        expect(data['data'].first['attributes']['follows_me']).to be false
      end

      it 'has follows_me: true if the user does follow me' do
        saruman.follow(user)

        get "/v1/users/#{gandalf.id}/following", headers: auth_headers

        expect(data['data'].first['attributes']['follows_me']).to be true
      end

      it 'has followed_by_me: false if I do not follow the user' do
        get "/v1/users/#{gandalf.id}/following", headers: auth_headers

        expect(data['data'].first['attributes']['followed_by_me']).to be false
      end

      it 'has followed_by_me: true if I do follow the user' do
        user.follow(saruman)

        get "/v1/users/#{gandalf.id}/following", headers: auth_headers

        expect(data['data'].first['id']).to eq saruman.id
        expect(data['data'].first['attributes']['followed_by_me']).to be true
      end
    end
  end
end
