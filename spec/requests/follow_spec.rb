require 'rails_helper'

RSpec.describe 'Follows', type: :request do
  let!(:user) { create_user_and_sign_in }
  let(:other_user) { Fabricate(:user) }
  let(:data) { JSON.parse(response.body) if response.body.present? }
  let(:auth_headers) { auth_headers_from_response }

  it 'can follow the other user' do
    post "/v1/follow/#{other_user.id}", headers: auth_headers

    expect(response.status).to eq 204

    expect(user.reload.follows?(other_user)).to be true
  end

  it 'can unfollow the other user' do
    user.follow(other_user)

    delete "/v1/follow/#{other_user.id}", headers: auth_headers

    expect(response.status).to eq 204

    expect(user.reload.follows?(other_user)).to be false
  end

  it 'errors if the user is already followed' do
    user.follow(other_user)

    post "/v1/follow/#{other_user.id}", headers: auth_headers

    expect(response.status).to eq 422

    expect(data['errors'].first).to be_present
  end
end
