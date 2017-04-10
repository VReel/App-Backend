require 'rails_helper'

RSpec.describe 'Timelines', type: :request do
  describe 'public timeline' do
    before(:each) { 25.times { create_post(Fabricate(:user), Faker::HarryPotter.quote) } }
    before(:each) { create_user_and_sign_in }
    before(:each) { get '/v1/public_timeline', headers: auth_headers_from_response }
    let(:data) { JSON.parse(response.body) if response.body.present? }
    let(:auth_headers) { auth_headers_from_response }

    it 'gets the most recent posts in the system' do
      expect(response.status).to eq 200
      expect(data['data'].size).to eq 20
      # Check the first one is the newest one.
      expect(data['data'].first['id']).to eq Post.all.order('created_at desc').first.id
    end

    it 'paginates the posts' do
      next_page_expectations
    end
  end
end
