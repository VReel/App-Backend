class S3PresignedPost
  include Swagger::Blocks

  swagger_path '/s3_presigned_post' do
    operation :get do
      key :summary, 'Get presigned post details for uploading to S3'
      key :description, 'Authorized users only'
      key :operationId, 's3_presigned_post'
      key :produces, [
        'application/json'
      ]
      key :tags, [
        'S3'
      ]
    end
  end
end
