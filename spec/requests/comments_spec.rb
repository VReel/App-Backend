require 'rails_helper'

RSpec.describe 'Comment requests', type: :request do
  let!(:user) { create_user_and_sign_in }
  let(:data) { JSON.parse(response.body) }
  let(:existing_post) { fabricate_post_for(user) }
  let(:auth_headers) { auth_headers_from_response }

  describe 'create a comment' do
    it 'succeeds when valid' do
      expect do
        post "/v1/posts/#{existing_post.id}/comments", params: {
          comment: { text: Faker::HarryPotter.quote }
        }, headers: auth_headers_from_response
      end.to change { Comment.count }.by 1

      expect(response.status).to eq 201
    end

    it 'increments the post comment_count' do
      expect do
        post "/v1/posts/#{existing_post.id}/comments", params: {
          comment: { text: Faker::HarryPotter.quote }
        }, headers: auth_headers_from_response
      end.to change { existing_post.reload.comment_count }.by 1
    end

    it 'fails when invalid' do
      expect do
        post "/v1/posts/#{existing_post.id}/comments", params: {
          comment: { other_key: 'something' }
        }, headers: auth_headers_from_response
      end.not_to change { Comment.count }

      expect(response.status).to eq 422
    end

    it 'fails when post is not found' do
      post "/v1/posts/#{SecureRandom.uuid}/comments", params: {
        comment: { text: Faker::HarryPotter.quote }
      }, headers: auth_headers_from_response

      expect(response.status).to eq 404
    end
  end

  describe 'update a comment' do
    let!(:comment) { existing_post.comments.create(user: user, text: Faker::HarryPotter.quote) }
    let(:new_comment_text) { Faker::Lorem.sentence }

    it 'succeeds when valid' do
      put "/v1/comments/#{comment.id}", params: {
        comment: { text: new_comment_text }
      }, headers: auth_headers_from_response

      expect(response.status).to eq 200
      expect(comment.reload.text).to eq new_comment_text
    end

    it 'fails when an invalid id is passed' do
      put "/v1/comments/#{SecureRandom.uuid}", params: {
        comment: { text: new_comment_text }
      }, headers: auth_headers_from_response

      expect(response.status).to eq 404
    end

    it 'fails when not owned by the current user' do
      other_user_comment = existing_post.comments.create(user: Fabricate(:user), text: Faker::HarryPotter.quote)

      put "/v1/comments/#{other_user_comment.id}", params: {
        comment: { text: new_comment_text }
      }, headers: auth_headers_from_response

      expect(response.status).to eq 404

      expect(other_user_comment.reload.text).not_to eq new_comment_text
    end

    it 'does not change the post comment_count' do
      expect do
        put "/v1/comments/#{comment.id}", params: {
          comment: { text: new_comment_text }
        }, headers: auth_headers_from_response
      end.not_to change { existing_post.reload.comment_count }
    end
  end

  describe 'delete a comment' do
    let!(:comment) { existing_post.comments.create(user: user, text: Faker::HarryPotter.quote) }

    it 'succeeds when valid' do
      expect do
        delete "/v1/comments/#{comment.id}", headers: auth_headers_from_response
      end.to change { Comment.count }.by(-1)

      expect(response.status).to eq 204
    end

    it 'decrements the post comment_count' do
      expect do
        delete "/v1/comments/#{comment.id}", headers: auth_headers_from_response
      end.to change { existing_post.reload.comment_count }.by(-1)
    end

    it 'fails when an invalid id is passed' do
      expect do
        delete "/v1/comments/#{SecureRandom.uuid}", headers: auth_headers_from_response
      end.not_to change { Comment.count }

      expect(response.status).to eq 404
    end

    it 'fails when not owned by the current user' do
      other_user_comment = existing_post.comments.create(user: Fabricate(:user), text: Faker::HarryPotter.quote)

      expect do
        delete "/v1/comments/#{other_user_comment.id}", headers: auth_headers_from_response
      end.not_to change { Comment.count }

      expect(response.status).to eq 404
    end
  end


  describe 'list comments' do
    let(:total_comments) { more_than_a_page_count }
    let(:auth_headers) { auth_headers_from_response }

    before(:each) do
      total_comments.times { existing_post.comments.create(user: user, text: Faker::HarryPotter.quote) }

      get "/v1/posts/#{existing_post.id}/comments", headers: auth_headers
    end

    it 'gets a page of posts' do
      first_page_expectations
    end

    it 'gets the next page of posts' do
      next_page_expectations(total: total_comments)
    end
  end
end
