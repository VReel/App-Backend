S3_REGION = {
  name: 'eu-west-1',
  s3_server_url: 'https://s3-eu-west-1.amazonaws.com'
}.freeze

Aws.config.update(
  region: S3_REGION[:name],
  credentials: Aws::Credentials.new(ENV['AWS_S3_ACCESS_KEY_ID'], ENV['AWS_S3_SECRET_ACCESS_KEY'])
)

S3_BUCKET = Aws::S3::Resource.new.bucket(ENV['AWS_S3_BUCKET'])
