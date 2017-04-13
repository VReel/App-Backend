require 'rails_helper'

RSpec.describe 'Get posts by other user', type: :request do
  let!(:user) { create_user_and_sign_in }
  let(:gandalf) { Fabricate(:user) }
  let(:data) { JSON.parse(response.body) }
  let(:total_posts) { more_than_a_page_count }
  let(:auth_headers) { auth_headers_from_response }

  describe 'list posts' do
    before(:each) do
      total_posts.times { fabricate_post_for(gandalf) }

      get "/v1/users/#{gandalf.id}/posts", headers: auth_headers
    end

    it 'gets the most recent post first' do
      expect(data['data'].first['id']).to eq Post.all.order('created_at desc').first.id
    end

    it 'gets a page of posts' do
      first_page_expectations
    end

    it 'gets the next page of posts' do
      next_page_expectations(total: total_posts)
    end
  end

  describe 'list liked posts' do
    before(:each) do
      total_posts.times do
        gandalf.like(fabricate_post_for(Fabricate(:user)))
      end

      get "/v1/users/#{gandalf.id}/likes", headers: auth_headers
    end

    it 'can get a page of posts liked by a user' do
      first_page_expectations
    end

    it 'can get the next page' do
      next_page_expectations(total: total_posts)
    end
  end
end
