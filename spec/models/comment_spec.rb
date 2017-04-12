require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:user) { Fabricate(:user) }
  let(:other_user) { Fabricate(:user) }
  let(:post) { create_post(user, caption: 'This is a #caption with #hash tags') }

  describe 'creating comments' do
    it 'updates the post comment count' do
      expect do
        post.comments.create(text: Faker::HarryPotter.quote, user: user)
      end.to change { post.reload.comment_count }.by 1
    end

    it 'adds hash tags to the post if the comment is by the post author' do
      comment = post.comments.create(text: 'This #comment has #some hash tags', user: user)
      expect(comment.has_hash_tags).to be true
      expect(post.reload.hash_tags.map(&:tag).sort).to eq %w(caption comment hash some)
    end

    it 'does not add hash tags to the post if the comment is by another user' do
      comment = post.comments.create(text: 'This #comment has #some hash tags', user: other_user)
      expect(comment.has_hash_tags).to be false
      expect(post.hash_tags.map(&:tag).sort).to eq %w(caption hash)
    end
  end

  describe 'updating comments' do
    let!(:comment) { post.comments.create(text: Faker::HarryPotter.quote, user: user) }
    let!(:other_user_comment) { post.comments.create(text: Faker::HarryPotter.quote, user: other_user) }

    it 'does not update the post comment count' do
      expect do
        comment.update(text: 'updated comment')
      end.not_to change { post.reload.comment_count }

      expect(comment.has_hash_tags).to be false
    end

    describe 'by post author' do
      it 'adds hash tags to the post' do
        comment.update(text: 'updated comment with #another hash tag')
        expect(comment.has_hash_tags).to be true
        expect(post.reload.hash_tags.map(&:tag).sort).to eq %w(another caption hash)
      end

      it 'deletes hash tags from the post' do
        comment.update(text: 'updated comment with #another hash tag')

        comment.update(text: 'updated comment without hash tag')
        expect(comment.has_hash_tags).to be false
        expect(post.reload.hash_tags.map(&:tag).sort).to eq %w(caption hash)
      end
    end

    describe 'by other user' do
      it 'does not add hash tags to the post' do
        other_user_comment.update(text: 'updated comment with #another hash tag')
        expect(other_user_comment.has_hash_tags).to be false
        expect(post.reload.hash_tags.map(&:tag).sort).to eq %w(caption hash)
      end

      it 'does not delete hash tags from the post' do
        other_user_comment.update(text: 'updated comment with #another hash tag')

        other_user_comment.update(text: 'updated comment without hash tag')
        expect(other_user_comment.has_hash_tags).to be false
        expect(post.reload.hash_tags.map(&:tag).sort).to eq %w(caption hash)
      end
    end
  end

  describe 'deleting comments' do
    let!(:comment) { post.comments.create(text: '#comment with hash tag', user: user) }
    let!(:other_user_comment) { post.comments.create(text: '#othercomment with hash tag', user: other_user) }

    it 'updates the post comment count' do
      expect do
        comment.destroy
      end.to change { post.reload.comment_count }.by(-1)
    end

    it 'removes hash tags from the post if the comment is by the post author' do
      expect(post.reload.hash_tags.map(&:tag).sort).to eq %w(caption comment hash)

      comment.destroy

      expect(post.reload.hash_tags.map(&:tag).sort).to eq %w(caption hash)
    end

    it 'does not remove hash tags from the post if the comment is by another user' do
      expect(post.reload.hash_tags.map(&:tag).sort).to eq %w(caption comment hash)

      other_user_comment.destroy

      expect(post.reload.hash_tags.map(&:tag).sort).to eq %w(caption comment hash)
    end
  end
end
