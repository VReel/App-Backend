require 'rails_helper'

RSpec.describe 'Hash tag search', type: :request do
  let!(:user) { create_user_and_sign_in }
  let(:data) { JSON.parse(response.body) if response.body.present? }
  let(:auth_headers) { auth_headers_from_response }

  describe 'searching for hash tags' do
    before(:each) do
      10.times { HashTag.create(tag: Faker::Name.first_name.downcase) }
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
      create_post('i like #iceccream')
      create_post('i hate #iceccream but like #chocolate')
      create_post('i love #iceccream but hate #chocolate')
    end

    it 'finds posts with the hash_tag by hash_tag' do
      get '/v1/posts/hash_tags/%23chocolate', headers: auth_headers

      expect(response.status).to eq 200
      expect(data['data'].size).to eq 2
    end

    it 'finds posts with the hash_tag by hash_tag_id' do
      hash_tag_id = HashTag.find_by_tag('#chocolate').id

      get "/v1/posts/hash_tags/#{hash_tag_id}", headers: auth_headers

      expect(response.status).to eq 200
      expect(data['data'].size).to eq 2
    end

    describe 'search result pagination posts' do
      before(:each) do
        25.times { create_post('i love #pizza') }

        get '/v1/posts/hash_tags/%23pizza', headers: auth_headers
      end

      it 'gets a page of posts' do
        expect(response.status).to eq 200
        expect(data['data'].size).to eq 20
      end

      it 'gets the next page of posts' do
        expect(data['links']['next']).to be_present
        expect(data['meta']['next_page']).to be true
        expect(data['meta']['next_page_id']).to be_present

        get data['links']['next'], headers: auth_headers

        expect(response.status).to eq 200

        new_data = JSON.parse(response.body)

        expect(new_data['data'].size).to eq 5

        expect(new_data['links']).to be_nil
        expect(new_data['meta']['next_page']).to be false
      end
    end
  end

  def create_post(caption)
    user.posts.create(
      original_key: "#{user.unique_id}/original",
      thumbnail_key: "#{user.unique_id}/thumbnail",
      caption: caption
    )
  end
end
