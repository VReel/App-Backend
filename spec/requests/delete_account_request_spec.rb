require 'rails_helper'

RSpec.describe 'Delete account requests', type: :request do
  let(:password) { 'I_liek_ham!' }
  let(:user) { Fabricate(:user, password: password, password_confirmation: password) }
  let(:data) { JSON.parse(response.body) }
  let(:random_number) { rand(10) + 1 }

  describe 'failure without authentication' do
    before(:each) do
      delete '/v1/users', headers: client_application_header
    end

    it 'should fail' do
      expect(response.status).to eq 401
    end

    it 'should an error' do
      expect(data['errors']).to be_present
    end

    it 'should not delete the user' do
      expect(User.find_by(email: user.email)).to be_present
    end
  end

  describe 'success with authentication' do
    before(:each) do
      post '/v1/users/sign_in', params: {
        login: user.email,
        password: password
      }, headers: client_application_header

      delete '/v1/users', headers: auth_headers_from_response
    end

    it 'should succeed' do
      expect(response.status).to eq 204
    end

    it 'should delete the user' do
      expect(User.find_by(email: user.email)).not_to be_present
    end
  end

  describe "delete user's assets and posts" do
    before(:each) do
      post '/v1/users/sign_in', params: {
        login: user.email,
        password: password
      }, headers: client_application_header

      25.times { fabricate_post_for(user) }
    end

    it 'deletes the posts' do
      expect do
        delete '/v1/users', headers: auth_headers_from_response
      end.to change { Post.where(user_id: user.id).count }.from(25).to(0)
    end

    it 'deletes the S3 assets' do
      all_keys = user.posts.map(&:original_key) + user.posts.map(&:thumbnail_key)

      # First we expect the database records to be deleted.
      expect_any_instance_of(S3DeletionService).to receive(:bulk_delete).with(all_keys.sort)
      # Then we expect anything remaining in the folder to be deleted.
      expect_any_instance_of(S3DeletionService).to receive(:bulk_delete).with([])

      delete '/v1/users', headers: auth_headers_from_response
    end

    it "deletes comments on the user's posts" do
      random_number.times do
        Comment.create(post: user.posts[rand(10)], user: Fabricate(:user), text: Faker::HarryPotter.quote)
      end

      expect do
        delete '/v1/users', headers: auth_headers_from_response
      end.to change { Comment.count }.from(random_number).to(0)
    end

    it "deletes likes on the user's posts" do
      random_number.times do
        Fabricate(:user).like(user.posts[rand(10)])
      end

      expect do
        delete '/v1/users', headers: auth_headers_from_response
      end.to change { Like.count }.from(random_number).to(0)
    end
  end

  describe "delete user's follower/following relationships" do
    let(:arthur) { create_user_and_sign_in }
    let(:dan) { Fabricate(:user) }
    let(:simone) { Fabricate(:user) }
    let(:bruno) { Fabricate(:user) }
    before(:each) do
      arthur.follow(dan)
      dan.follow(arthur)
      arthur.follow(simone)
      simone.follow(arthur)
      dan.follow(simone)
      simone.follow(dan)
      arthur.follow(bruno)
      bruno.follow(simone)
    end

    it 'has the correct following/follower counts' do
      arthur.reload
      simone.reload
      dan.reload
      bruno.reload

      expect(arthur.following_count).to eq 3
      expect(arthur.follower_count).to eq 2
      expect(dan.following_count).to eq 2
      expect(dan.follower_count).to eq 2
      expect(simone.following_count).to eq 2
      expect(simone.follower_count).to eq 3
      expect(bruno.following_count).to eq 1
      expect(bruno.follower_count).to eq 1
    end

    it 'deletes follower_relationships' do
      expect do
        delete '/v1/users', headers: auth_headers_from_response
      end.to change { deleted_arthur.following_relationships.count }.by(-3)

      expect(deleted_arthur.following_relationships.count).to be 0
    end

    it 'deletes_following_relationships' do
      expect do
        delete '/v1/users', headers: auth_headers_from_response
      end.to change { deleted_arthur.follower_relationships.count }.by(-2)

      expect(deleted_arthur.follower_relationships.count).to be 0
    end

    it 'updates follower_counts' do
      delete '/v1/users', headers: auth_headers_from_response

      # People who arthur folowed have their follower count decremented.
      expect(dan.reload.follower_count).to eq 1
      expect(simone.reload.follower_count).to eq 2
      expect(bruno.reload.follower_count).to eq 0
    end

    it 'updates following_counts' do
      delete '/v1/users', headers: auth_headers_from_response

      # People who arthur folowed have their follower count decremented.
      expect(dan.reload.following_count).to eq 1
      expect(simone.reload.following_count).to eq 1
      expect(bruno.reload.following_count).to eq 1
    end

    def deleted_arthur
      User.with_deleted.find_by(id: arthur.id)
    end
  end

  describe "delete user's comments" do
    let(:comment_count) { rand(5) + 2 }
    let!(:user) { create_user_and_sign_in }
    before(:each) do
      comment_count.times { create_post(Fabricate(:user)).comments.create(user: user, text: Faker::HarryPotter.quote) }
    end

    it 'deletes the posts' do
      expect do
        delete '/v1/users', headers: auth_headers_from_response
      end.to change { Comment.count }.from(comment_count).to(0)
    end
  end

  describe "delete user's likes" do
    let(:like_count) { rand(5) + 2 }
    let!(:user) { create_user_and_sign_in }
    before(:each) do
      like_count.times { user.like(create_post(Fabricate(:user))) }
    end

    it 'deletes the posts' do
      expect do
        delete '/v1/users', headers: auth_headers_from_response
      end.to change { Like.count }.from(like_count).to(0)
    end
  end
end
