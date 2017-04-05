module S3Urls
  extend ActiveSupport::Concern

  def original_url
    S3_BUCKET.object(original_key).presigned_url(:get, expires_in: 120) if original_key.present?
  end

  def thumbnail_url
    S3_BUCKET.object(thumbnail_key).presigned_url(:get, expires_in: 120) if thumbnail_key.present?
  end
end
