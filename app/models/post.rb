class Post < ApplicationRecord
  belongs_to :user
  validates :original_key, presence: true
  validates :thumbnail_key, presence: true
  validates :user_id, presence: true

  before_update { self.edited = true if caption_changed? }
  before_destroy { Post.delay.delete_s3_resources([thumbnail_key, original_key]) }

  def original_url
    S3_BUCKET.object(original_key).presigned_url(:get, expires_in: 120)
  end

  def thumbnail_url
    S3_BUCKET.object(thumbnail_key).presigned_url(:get, expires_in: 120)
  end

  # This is a class method so doesn't rely on existence of record.
  def self.delete_s3_resources(keys)
    s3_deletion_service = S3DeletionService.new

    keys.each { |key| s3_deletion_service.delete(key) }
  end
end
