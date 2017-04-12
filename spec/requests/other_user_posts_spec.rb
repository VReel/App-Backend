require 'rails_helper'

RSpec.describe 'Get posts by other user', type: :request do
  let!(:user) { create_user_and_sign_in }
  let(:gandalf) { Fabricate(:user) }
  let(:data) { JSON.parse(response.body) }

  describe 'list posts' do
    let(:total_posts) { more_than_a_page_count }
    let(:auth_headers) { auth_headers_from_response }

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
end
