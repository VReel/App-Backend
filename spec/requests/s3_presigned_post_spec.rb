require 'rails_helper'

RSpec.describe 'S3 presigned post', type: :request do
  before(:each) do
    create_user_and_sign_in
    get '/v1/s3_presigned_post', headers: auth_headers_from_response
  end

  let(:data) { JSON.parse(response.body) }

  it 'request is successful' do
    expect(response.status).to eq 200
  end

  it 'presigned post details are returned' do
    expect(data['data']['attributes']['thumbnail']).to be_present
    expect(data['data']['attributes']['original']).to be_present
  end
end
