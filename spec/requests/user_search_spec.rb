require 'rails_helper'

RSpec.describe 'User search', type: :request do
  before(:each) { create_user_and_sign_in }
  before(:each) do
    10.times { Fabricate(:user) }
  end
  let!(:hannibal) { Fabricate(:user, name: 'Hannibal Hayes', handle: 'hannibal') }
  let!(:ba) { Fabricate(:user, name: 'B.A. Baracus', handle: 'Mr_T') }
  let(:data) { JSON.parse(response.body) if response.body.present? }
  let(:user_ids) { data['data'].map { |result| result['id'] } }
  let(:auth_headers) { auth_headers_from_response }

  it 'can find results by handle' do
    get '/v1/search/users/han', headers: auth_headers

    expect(response.status).to eq 200
    expect(data['data'].size).to be > 0
    expect(user_ids).to include hannibal.id
  end

  it 'can find results by name' do
    get '/v1/search/users/b%2Ea%2E', headers: auth_headers

    expect(response.status).to eq 200
    expect(data['data'].size).to be > 0
    expect(user_ids).to include ba.id
  end

  it 'can find results by surname' do
    get '/v1/search/users/hay', headers: auth_headers

    expect(response.status).to eq 200
    expect(data['data'].size).to be > 0
    expect(user_ids).to include hannibal.id
  end

  it 'does not find mid-string matches' do
    get '/v1/search/users/annibal', headers: auth_headers

    expect(response.status).to eq 200
    expect(data['data'].size).to eq 0

    get '/v1/search/users/ayes', headers: auth_headers

    expect(response.status).to eq 200
    expect(data['data'].size).to eq 0

    get '/v1/search/users/_T', headers: auth_headers

    expect(response.status).to eq 200
    expect(data['data'].size).to eq 0
  end

  it 'does not find false matches' do
    get '/v1/search/users/zzzyyyxxxxaafsasf', headers: auth_headers

    expect(response.status).to eq 200
    expect(data['data'].size).to eq 0
  end

  it 'is accessable by guests' do
    get '/v1/search/users/zzzyyyxxxxaafsasf', headers: client_application_header

    expect(response.status).to eq 200
    expect(data['data'].size).to eq 0
  end

  it 'errors if no search term' do
    expect do
      get '/v1/search/users/', headers: auth_headers
    end.to raise_error ActionController::RoutingError
  end
end
