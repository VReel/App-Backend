module S3Urls
  extend ActiveSupport::Concern

  def original_url
    S3_BUCKET.object(original_key).presigned_url(:get, expires_in: 120) if original_key.present?
  end

  def thumbnail_url
    S3_BUCKET.object(thumbnail_key).presigned_url(:get, expires_in: 120) if thumbnail_key.present?
  end

  protected

  def valid_keys
    validate_folder
    validate_presence_of_pair
  end

  # rubocop:disable Metrics/AbcSize
  def validate_folder
    errors.add(:original_key, 'invalid path') if original_key.present? && !original_key.start_with?(s3_folder)
    errors.add(:thumbnail_key, 'invalid path') if thumbnail_key.present? && !thumbnail_key.start_with?(s3_folder)
  end
  # rubocop:enable Metrics/AbcSize

  def validate_presence_of_pair
    errors.add(:original_key, 'must be updated if thumbnail_key is updated') if thumbnail_key_changed? && !original_key_changed?
    errors.add(:thumbnail_key, 'must be updated if original_key is updated') if original_key_changed? && !thumbnail_key_changed?
  end
end
