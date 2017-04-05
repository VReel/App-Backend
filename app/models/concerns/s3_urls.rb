module S3Urls
  extend ActiveSupport::Concern

  def original_url
    S3_BUCKET.object(original_key).presigned_url(:get, expires_in: 120) if original_key.present?
  end

  def thumbnail_url
    S3_BUCKET.object(thumbnail_key).presigned_url(:get, expires_in: 120) if thumbnail_key.present?
  end

  module ClassMethods
    # This is a class method so doesn't rely on existence of record.
    def delete_s3_resources(keys)
      s3_deletion_service = S3DeletionService.new

      keys.each { |key| s3_deletion_service.delete(key) }
    end
  end
end
