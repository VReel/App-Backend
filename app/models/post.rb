class Post < ApplicationRecord
  belongs_to :user
  validates :original_key, presence: true
  validates :thumbnail_key, presence: true
  validates :user_id, presence: true

  before_update { self.edited = true if caption_changed? }
  before_destroy { delete_s3_resources }

  def original_url
    S3_BUCKET.object(original_key).presigned_url(:get, expires_in: 120)
  end

  def thumbnail_url
    S3_BUCKET.object(thumbnail_key).presigned_url(:get, expires_in: 120)
  end

  def delete_s3_resources
    # These seem to respond the same way whether the key exists or not.
    return if Rails.env.test?

    S3_BUCKET.object(thumbnail_key).delete
    S3_BUCKET.object(original_key).delete
  end
end
