class Post < ApplicationRecord
  include S3Urls
  include IncrementDecrement
  belongs_to :user
  validates :original_key, presence: true
  validates :thumbnail_key, presence: true
  validates :user_id, presence: true
  validate :valid_keys

  before_update { self.edited = true if caption_changed? }
  before_destroy { Post.delay.delete_s3_resources([thumbnail_key, original_key]) }

  after_create { increment(user, :post_count) }
  after_destroy { decrement(user, :post_count) }

  # This is a class method so doesn't rely on existence of record.
  def self.delete_s3_resources(keys)
    s3_deletion_service = S3DeletionService.new

    keys.each { |key| s3_deletion_service.delete(key) }
  end

  def s3_folder
    user.unique_id
  end
end
