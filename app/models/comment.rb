class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post

  before_save :set_has_hash_tags
  after_save :update_post_hash_tags
  after_destroy :update_post_hash_tags
  after_create { post.locked_increment(:comment_count) }
  after_destroy { post.locked_decrement(:comment_count) }

  validates :text, length: { maximum: 500 }

  def comment_is_by_post_author?
    user_id == post.user_id
  end

  def set_has_hash_tags
    return unless text_changed?

    self.has_hash_tags = comment_is_by_post_author? && HashTag.find_in(text).any?
  end

  def update_post_hash_tags
    return unless has_hash_tags || has_hash_tags_was

    post.set_hash_tags!
  end
end
