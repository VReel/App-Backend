class Post < ApplicationRecord
  include S3Urls
  belongs_to :user
  validates :original_key, presence: true
  validates :thumbnail_key, presence: true
  validates :user_id, presence: true
  validate :valid_keys

  before_update { self.edited = true if caption_changed? }
  before_destroy { Post.delay.delete_s3_resources([thumbnail_key, original_key]) }

  protected

  def valid_keys
    errors.add(:original_key, 'invalid path') unless original_key.try(:start_with?, user.unique_id)
    errors.add(:thumbnail_key, 'invalid path') unless thumbnail_key.try(:start_with?, user.unique_id)
  end
end
