class S3Service
  attr_reader :date_string, :uuid, :user

  def initialize(user)
    @date_string = Time.current.strftime('%Y_%m_%d_%H_%M_%S')
    @uuid = SecureRandom.uuid
    @user = user
  end

  def full_image_presigned_post_fields
    post = presigned_post('full')
    post.fields.merge(url: post.url)
  end

  def thumbnail_presigned_post_fields
    post = presigned_post('thumbnail')
    post.fields.merge(url: post.url)
  end

  def presigned_post(filename)
    S3_BUCKET.presigned_post(
      key: "/#{user.unique_id}/#{date_string}/#{uuid}-#{filename}",
      success_action_status: '201',
      acl: 'public-read'
    )
  end
end
