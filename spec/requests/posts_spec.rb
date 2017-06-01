require 'rails_helper'

RSpec.describe 'Post requests', type: :request do
  let!(:user) { create_user_and_sign_in }
  let(:data) { JSON.parse(response.body) }
  let(:existing_post) { fabricate_post_for(user) }
  let(:auth_headers) { auth_headers_from_response }

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

    describe 'push notifications' do
      let(:follower_1) { Fabricate(:user_with_device) }
      let(:follower_2) { Fabricate(:user_with_device) }
      before(:each) do
        follower_1.follow(user)
        follower_2.follow(user)
      end

      it 'sends a push notifications to followers of the poster' do
        expect(OneSignal::Notification).to(
          receive(:create).with(one_signal_packet_with_player_ids(follower_1.device_ids + follower_2.device_ids))
        )

        post '/v1/posts', params: {
          post: new_post.attributes.slice('original_key', 'thumbnail_key', 'caption')
        }, headers: auth_headers_from_response

        expect(response.status).to eq 201
      end

      it 'sends multiple push notifications to large batches of followers' do
        ENV['ONE_SIGNAL_BATCH_SIZE'] = '1'

        expect(OneSignal::Notification).to receive(:create).twice

        post '/v1/posts', params: {
          post: new_post.attributes.slice('original_key', 'thumbnail_key', 'caption')
        }, headers: auth_headers_from_response

        expect(response.status).to eq 201
      end
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

    describe "deletes the post's comments" do
      let(:comment_count) { rand(5) + 2 }
      before(:each) do
        comment_count.times { existing_post.comments.create(user: Fabricate(:user), text: Faker::HarryPotter.quote) }
      end

      it 'deletes the comments' do
        expect do
          delete  "/v1/posts/#{existing_post.id}", headers: auth_headers_from_response
        end.to change { Comment.count }.from(comment_count).to(0)
      end
    end

    describe "deletes the post's likes" do
      let(:like_count) { rand(5) + 2 }
      before(:each) do
        like_count.times { Fabricate(:user).like(existing_post) }
      end

      it 'deletes the likes' do
        expect do
          delete  "/v1/posts/#{existing_post.id}", headers: auth_headers_from_response
        end.to change { Like.count }.from(like_count).to(0)
      end
    end

    describe "updates the post's flags to :post_deleted" do
      let(:flag_count) { rand(5) + 2 }
      before(:each) do
        flag_count.times { existing_post.flags.create(user: Fabricate(:user), reason: Faker::HarryPotter.quote) }
      end

      it 'updates the flags' do
        expect do
          delete  "/v1/posts/#{existing_post.id}", headers: auth_headers_from_response
        end.to change { Flag.pending.count }.from(flag_count).to(0)
      end
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

    it 'tells me whether I like it' do
      get "/v1/posts/#{existing_post.id}", headers: auth_headers
      expect(data['data']['attributes']['liked_by_me']).to be false

      user.like(existing_post)

      get "/v1/posts/#{existing_post.id}", headers: auth_headers
      expect(JSON.parse(response.body)['data']['attributes']['liked_by_me']).to be true
    end
  end

  describe 'list posts' do
    let(:total_posts) { more_than_a_page_count }
    let(:random_number) { rand(4) + 1 }

    before(:each) do
      total_posts.times { fabricate_post_for(user) }

      get '/v1/posts', headers: auth_headers
    end

    it 'gets a page of posts' do
      first_page_expectations
    end

    it 'gets the next page of posts' do
      next_page_expectations(total: total_posts)
    end

    it 'shows which posts I like' do
      liked_post1 = Post.all.order('created_at DESC')[random_number]
      liked_post2 = Post.all.order('created_at DESC')[random_number * 2]
      user.like(liked_post1)
      user.like(liked_post2)

      get '/v1/posts', headers: auth_headers

      liked_posts_in_response = data['data'].select { |post| post['attributes']['liked_by_me'] }
      expect(liked_posts_in_response.map { |post| post['id'] }).to eq [liked_post1.id, liked_post2.id]
    end
  end
end
