require 'rails_helper'

RSpec.describe 'Users', type: :request do
  before(:each) { create_user_and_sign_in }
  before(:each) { get "/v1/users/#{other_user.id}", headers: auth_headers }
  let(:other_user) { Fabricate(:user, profile: 'some profile') }
  let(:data) { JSON.parse(response.body) if response.body.present? }
  let(:auth_headers) { auth_headers_from_response }

  it 'can view full user details' do
    expect(response.status).to eq 200
    expect(data['data']['id']).to eq other_user.id
    # Ensure we have the full packet details.
    expect(data['data']['attributes']['profile']).to be_present
  end

  it 'cannot see the email of another user' do
    expect(data['data']['attributes']['email']).to be_nil
  end
end
