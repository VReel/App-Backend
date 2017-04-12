require 'rails_helper'

RSpec.describe 'Likes', type: :request do
  let!(:user) { create_user_and_sign_in }
  let!(:liked_post) { create_post(Fabricate(:user), Faker::HarryPotter.quote) }
  let(:data) { JSON.parse(response.body) if response.body.present? }
  let(:auth_headers) { auth_headers_from_response }

  it 'can like a post' do
    post "/v1/like/#{liked_post.id}", headers: auth_headers

    expect(response.status).to eq 204

    expect(user.reload.likes?(liked_post)).to be true
  end

  it 'can unlike a post' do
    user.like(liked_post)

    delete "/v1/like/#{liked_post.id}", headers: auth_headers

    expect(response.status).to eq 204

    expect(user.reload.likes?(liked_post)).to be false
  end

  it 'errors if the post is already liked' do
    user.like(liked_post)

    post "/v1/like/#{liked_post.id}", headers: auth_headers

    expect(response.status).to eq 422

    expect(data['errors'].first).to be_present
  end
end
