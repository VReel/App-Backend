require 'rails_helper'

RSpec.describe 'Post requests', type: :request do
  let!(:user) { create_user_and_sign_in }
  let(:data) { JSON.parse(response.body) }
  let(:existing_post) { fabricate_post_for(user) }

  describe 'create a post' do
    let!(:new_post) { fabricate_post_for(user) }

    it 'succeeds when valid' do
      expect do
        post '/v1/posts', params: {
          post: new_post.attributes.slice('original_key', 'thumbnail_key', 'caption')
        }, headers: auth_headers_from_response
      end.to change { Post.count }.by 1

      expect(response.status).to eq 201
    end

    it 'increments the users post_count' do
      expect do
        post '/v1/posts', params: {
          post: new_post.attributes.slice('original_key', 'thumbnail_key', 'caption')
        }, headers: auth_headers_from_response
      end.to change { user.reload.post_count }.by 1
    end

    it 'fails when invalid' do
      expect do
        post '/v1/posts', params: {
          post: new_post.attributes.slice('original_key', 'caption')
        }, headers: auth_headers_from_response
      end.not_to change { Post.count }

      expect(response.status).to eq 422
    end

    it 'fails with invalid keys' do
      expect do
        post '/v1/posts', params: {
          post: new_post.attributes.slice('original_key', 'caption').merge(thumbnail_key: 'invalid_key')
        }, headers: auth_headers_from_response
      end.not_to change { Post.count }

      expect(response.status).to eq 422
      # Error references correct field.
      expect(data['errors'].first['source']['pointer']).to eq '/data/attributes/thumbnail_key'
    end
  end

  describe 'update a post' do
    let(:caption) { Faker::HarryPotter.quote * 2 }

    it 'succeeds when valid' do
      put "/v1/posts/#{existing_post.id}", params: {
        post: { caption: caption }
      }, headers: auth_headers_from_response

      expect(response.status).to eq 200
      expect(existing_post.reload.caption).to eq caption
      expect(existing_post.reload.edited).to be true
    end

    it 'fails when an invalid id is passed' do
      put '/v1/posts/not-a-real-id', params: {
        post: { caption: caption }
      }, headers: auth_headers_from_response

      expect(response.status).to eq 404
      expect(existing_post.reload.caption).not_to eq caption
    end

    it 'fails when not owned by the current user' do
      other_post = fabricate_post_for(Fabricate(:user))

      put "/v1/posts/#{other_post.id}", params: {
        post: { caption: caption }
      }, headers: auth_headers_from_response

      expect(response.status).to eq 404
      expect(existing_post.reload.caption).not_to eq caption
    end

    it 'does not change the users post_count' do
      existing_post

      expect do
        put "/v1/posts/#{existing_post.id}", params: {
          post: { caption: caption }
        }, headers: auth_headers_from_response
      end.not_to change { user.reload.post_count }
    end
  end

  describe 'delete a post' do
    before(:each) { existing_post }

    it 'succeeds when valid' do
      expect do
        delete "/v1/posts/#{existing_post.id}", headers: auth_headers_from_response
      end.to change { Post.count }.by(-1)

      expect(response.status).to eq 204
    end

    it 'decrements the users post_count' do
      existing_post

      expect do
        delete "/v1/posts/#{existing_post.id}", headers: auth_headers_from_response
      end.to change { user.reload.post_count }.by(-1)

      expect(response.status).to eq 204
    end

    it 'fails when an invalid id is passed' do
      expect do
        delete '/v1/posts/some_other_id', headers: auth_headers_from_response
      end.not_to change { Post.count }

      expect(response.status).to eq 404
    end

    it 'deletes the underlying S3 resources' do
      expect_any_instance_of(S3DeletionService).to receive(:delete).with(existing_post.thumbnail_key)
      expect_any_instance_of(S3DeletionService).to receive(:delete).with(existing_post.original_key)

      delete "/v1/posts/#{existing_post.id}", headers: auth_headers_from_response
    end

    it 'fails when not owned by the current user' do
      other_post = fabricate_post_for(Fabricate(:user))
      expect do
        delete "/v1/posts/#{other_post.id}", headers: auth_headers_from_response
      end.not_to change { Post.count }

      expect(response.status).to eq 404
    end
  end

  describe 'show a post' do
    it 'succeeds when valid' do
      get "/v1/posts/#{existing_post.id}", headers: auth_headers_from_response
      expect(response.status).to eq 200
      expect(data['data']['attributes']['caption']).to eq existing_post.caption
    end

    it 'has the full details' do
      get "/v1/posts/#{existing_post.id}", headers: auth_headers_from_response
      %w(thumbnail_url original_url caption edited created_at).each do |key|
        expect(data['data']['attributes'][key]).not_to be_nil
      end
    end

    it 'fails when an invalid id is passed' do
      get '/v1/posts/some_other_id', headers: auth_headers_from_response
      expect(response.status).to eq 404
    end
  end

  describe 'list posts' do
    before(:each) do
      25.times { fabricate_post_for(user) }

      # For some reason this fails in the full test suite if we don't memoize headers.
      @auth_headers = auth_headers_from_response
      get '/v1/posts', headers: @auth_headers
    end

    it 'gets a page of posts' do
      expect(response.status).to eq 200
      expect(data['data'].size).to eq 20
    end

    it 'gets the next page of posts' do
      expect(data['links']['next']).to be_present
      expect(data['meta']['next_page']).to be true
      expect(data['meta']['next_page_id']).to be_present

      get data['links']['next'], headers: @auth_headers

      expect(response.status).to eq 200

      new_data = JSON.parse(response.body)

      expect(new_data['data'].size).to eq 5

      expect(new_data['links']).to be_nil
      expect(new_data['meta']['next_page']).to be false
    end
  end
end
