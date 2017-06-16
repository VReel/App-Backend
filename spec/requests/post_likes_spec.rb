require 'rails_helper'

RSpec.describe 'Post likes', type: :request do
  let!(:user) { create_user_and_sign_in }
  let(:dan) { Fabricate(:user) }
  let(:arthur) { Fabricate(:user) }
  let(:liked_post) { create_post(Fabricate(:user)) }
  let(:data) { JSON.parse(response.body) if response.body.present? }
  let(:auth_headers) { auth_headers_from_response }

  describe 'a user who likes the post appears in the list of post likers' do
    it 'shows a user in the list of liked posts' do
      dan.like(liked_post)

      get "/v1/posts/#{liked_post.id}/likes", headers: auth_headers

      expect(response.status).to eq 200
      expect(data['data'].first['id']).to eq dan.id
    end

    it 'orders the users by who liked it oldest first' do
      dan.like(liked_post)
      arthur.like(liked_post)

      get "/v1/posts/#{liked_post.id}/likes", headers: auth_headers

      expect(response.status).to eq 200
      expect(data['data'].map { |user| user['id'] }).to eq [dan.id, arthur.id]
    end
  end

  describe 'pagination' do
    let(:liker_count) { 22 }
    before(:each) do
      liker_count.times { Fabricate(:user).like(liked_post) }

      get "/v1/posts/#{liked_post.id}/likes", headers: auth_headers
    end

    it 'gets oldest liker first' do
      expect(data['data'].first['id']).to eq Like.where(post: liked_post).order('created_at ASC').first.user_id
    end

    it 'gets a page of likers' do
      first_page_expectations

      expect_page_id_to_match(
        data['meta']['next_page_id'],
        Like.where(post: liked_post).order('created_at ASC')[API_PAGE_SIZE - 1]
      )
    end

    it 'gets the next page of likers' do
      next_page_expectations(total: liker_count)
    end
  end

  describe 'follows flags' do
    let(:other_user) { Fabricate(:user) }
    before(:each) do
      other_user.like(liked_post)
    end

    describe 'followed_by_me' do
      it 'has followed_by_me: false if I do not follow that user' do
        get "/v1/posts/#{liked_post.id}/likes", headers: auth_headers

        expect(data['data'].first['attributes']['followed_by_me']).to be false
      end

      it 'has followed_by_me: true if I follow that user' do
        user.follow(other_user)

        get "/v1/posts/#{liked_post.id}/likes", headers: auth_headers

        expect(data['data'].first['attributes']['followed_by_me']).to be true
      end
    end

    describe 'follows_me' do
      it 'has follows_me: false if user does not follow me' do
        get "/v1/posts/#{liked_post.id}/likes", headers: auth_headers

        expect(data['data'].first['attributes']['follows_me']).to be false
      end

      it 'has follows_me: true if user follows me' do
        other_user.follow(user)

        get "/v1/posts/#{liked_post.id}/likes", headers: auth_headers

        expect(data['data'].first['attributes']['follows_me']).to be true
      end
    end
  end
end
