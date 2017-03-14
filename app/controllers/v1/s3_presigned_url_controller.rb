class V1::S3PresignedUrlController < ApplicationController
  def index
    render json:
      {
        data: {
          type: 'S3 presigned urls',
          attributes: {
            original: s3_upload_service.original_image_presigned_url,
            thumbnail: s3_upload_service.thumbnail_image_presigned_url
          }
        }
      }
  end

  protected

  def s3_upload_service
    @s3_upload_service ||= S3UploadService.new(current_user)
  end
end
