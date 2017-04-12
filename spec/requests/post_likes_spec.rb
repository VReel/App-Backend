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

    it 'orders the users by who liked it most recent first' do
      dan.like(liked_post)
      arthur.like(liked_post)

      get "/v1/posts/#{liked_post.id}/likes", headers: auth_headers

      expect(response.status).to eq 200
      expect(data['data'].map { |user| user['id'] }).to eq [arthur.id, dan.id]
    end
  end

  describe 'pagination' do
    let(:liker_count) { more_than_a_page_count }
    before(:each) do
      liker_count.times { Fabricate(:user).like(liked_post) }

      get "/v1/posts/#{liked_post.id}/likes", headers: auth_headers
    end

    it 'gets a page of likers' do
      first_page_expectations
    end

    it 'gets the next page of likers' do
      next_page_expectations(total: liker_count)
    end
  end
end
