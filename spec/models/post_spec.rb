require 'rails_helper'

RSpec.describe Post, type: :model do
  let(:user) { Fabricate(:user) }

  describe 'hash tag indexing' do
    it 'creates a hash tag for a brand new hash tag' do
      post = nil

      expect do
        post = create_post('this post has a #single hash tag')
      end.to change { HashTag.count }.by 1

      expect(post.hash_tags.size).to eq 1
      expect(post.hash_tags.first.tag).to eq 'single'
    end

    it 'creates an association for an existing hash tag' do
      HashTag.create(tag: 'existing')
      post = nil

      expect do
        post = create_post('this post has an #existing hash tag')
      end.not_to change { HashTag.count }

      expect(post.hash_tags.size).to eq 1
      expect(post.hash_tags.first.tag).to eq 'existing'
    end

    it 'creates multiple hash_tag associations' do
      HashTag.create(tag: 'multiple')
      post = nil

      expect do
        post = create_post('this post has a #multiple #hash #tags')
      end.to change { HashTag.count }.by 2

      expect(post.hash_tags.size).to eq 3
      expect(post.hash_tags.map(&:tag).sort).to eq ['hash', 'multiple', 'tags']
    end

    it 'removes hash tags associations that are removed from the caption' do
      post = create_post('this post has a #multiple #hash #tags but one will be #deleted')
      expect(post.hash_tags.size).to eq 4

      post.update(caption: 'this post has a #multiple #hash #tags')
      expect(post.hash_tags.size).to eq 3
      expect(post.hash_tags.map(&:tag).sort).to eq ['hash', 'multiple', 'tags']
    end

    it 'removes hash tags that no longer associated with anything' do
      prior_post = create_post('this will create an #existing hash tag')
      post = create_post('this will create an #existing hash tag and a #new hash tag')

      expect(post.hash_tags.size).to eq 2

      expect {
        post.update(caption: 'this has no hash tags')
      }.to change { HashTag.count }.by -1

      expect(post.hash_tags.size).to eq 0
    end
  end

  describe 'deleting a post' do
    it 'removes hash tag assocations' do
      post = create_post('this will create an #existing hash tag and a #new hash tag')

      expect {
        post.destroy
      }.to change { HashTagPost.count }.by -2

    end

    it 'removes hash tags that no longer associated with anything' do
      prior_post = create_post('this will create an #existing hash tag')
      post = create_post('this will create an #existing hash tag and a #new hash tag')

      expect {
        post.destroy
      }.to change { HashTag.count }.by -1
    end
  end

  def create_post(caption)
    post = user.posts.create(
      original_key: "#{user.unique_id}/original",
      thumbnail_key: "#{user.unique_id}/thumbnail",
      caption: caption
    )
  end
end
