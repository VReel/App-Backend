class S3UploadService
  attr_reader :date_string, :uuid, :user

  def initialize(user)
    @date_string = Time.current.strftime('%Y_%m_%d_%H_%M_%S')
    @uuid = SecureRandom.uuid
    @user = user
  end

  def original_image_presigned_url
    key = key_for('original')
    {
      key: key,
      url: url_for_key(key, :put)
    }
  end

  def thumbnail_image_presigned_url
    key = key_for('thumbnail')
    {
      key: key,
      url: url_for_key(key, :put)
    }
  end

  protected

  def key_for(filename)
    "#{user.unique_id}/#{date_string}_#{uuid}-#{filename}"
  end

  def url_for_key(key, method)
    S3_BUCKET.object(key).presigned_url(method, expires_in: 300)
  end
end
