class Post < ApplicationRecord
  belongs_to :user
  validates :original_key, presence: true
  validates :thumbnail_key, presence: true
  validates :user_id, presence: true

  before_update { self.edited = true if caption_changed? }

  def original_url
    S3_BUCKET.object(original_key).presigned_url(:get, expires_in: 120)
  end

  def thumbnail_url
    S3_BUCKET.object(thumbnail_key).presigned_url(:get, expires_in: 120)
  end
end
