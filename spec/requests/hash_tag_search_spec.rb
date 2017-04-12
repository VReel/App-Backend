require 'rails_helper'

RSpec.describe 'Hash tag search', type: :request do
  let!(:user) { create_user_and_sign_in }
  let(:data) { JSON.parse(response.body) if response.body.present? }
  let(:auth_headers) { auth_headers_from_response }

  describe 'searching for hash tags' do
    before(:each) do
      10.times { |i| HashTag.create(tag: "#{Faker::Name.first_name.downcase}#{i}") }
    end
    let(:hash_tag) { HashTag.first }
    let(:hash_tag_ids) { data['data'].map { |result| result['id'] } }

    it 'can find results' do
      get "/v1/search/hash_tags/#{hash_tag.tag.first}", headers: auth_headers

      expect(response.status).to eq 200
      expect(data['data'].size).to be > 0
      expect(hash_tag_ids).to include hash_tag.id
    end
  end

  describe 'search for posts with hash tags' do
    before(:each) do
      create_post(user, 'i like #iceccream')
      create_post(user, 'i hate #iceccream but like #chocolate')
      create_post(user, 'i love #iceccream but hate #chocolate')
    end

    it 'finds posts with the hash_tag by hash_tag' do
      get '/v1/posts/hash_tags/%23chocolate', headers: auth_headers

      expect(response.status).to eq 200
      expect(data['data'].size).to eq 2
    end

    it 'includes the user details of the post' do
      get '/v1/posts/hash_tags/%23chocolate', headers: auth_headers

      expect(data['data'].first['relationships']['user']['data']['id']).to eq user.id
      expect(data['included'].first['id']).to eq user.id
    end

    it 'finds posts with the hash_tag by hash_tag_id' do
      hash_tag_id = HashTag.find_with_tag('#chocolate').id

      get "/v1/posts/hash_tags/#{hash_tag_id}", headers: auth_headers

      expect(response.status).to eq 200
      expect(data['data'].size).to eq 2
    end

    describe 'search result pagination posts' do
      let(:total_posts) { more_than_a_page_count }
      before(:each) do
        total_posts.times { create_post(user, 'i love #pizza') }

        get '/v1/posts/hash_tags/%23pizza', headers: auth_headers
      end

      it 'gets a page of posts' do
        first_page_expectations
      end

      it 'gets the next page of posts' do
        next_page_expectations(total: total_posts)
      end
    end
  end
end
