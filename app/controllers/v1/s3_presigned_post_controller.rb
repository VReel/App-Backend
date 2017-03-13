class V1::S3PresignedPostController < ApplicationController
  def index
    render json:
      {
        data: {
          type: 'S3 Credentials',
          attributes: {
            full: s3_service.full_image_presigned_post_fields.as_json,
            thumbnail: s3_service.thumbnail_presigned_post_fields.as_json
          }
        }
      }
  end

  protected

  def s3_service
    @s3_service ||= S3Service.new(current_user)
  end
end
