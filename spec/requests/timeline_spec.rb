require 'rails_helper'

RSpec.describe 'Timelines', type: :request do
  let(:data) { JSON.parse(response.body) if response.body.present? }
  let(:auth_headers) { auth_headers_from_response }

  describe 'public timeline' do
    before(:each) { 25.times { create_post(Fabricate(:user), Faker::HarryPotter.quote) } }
    before(:each) { create_user_and_sign_in }
    before(:each) { get '/v1/public_timeline', headers: auth_headers }

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

  describe 'user timeline' do
    let(:arthur) { create_user_and_sign_in }
    let(:dan) { Fabricate(:user) }
    let(:simone) { Fabricate(:user) }
    let(:bruno) { Fabricate(:user) }

    before(:each) do
      8.times { create_post(dan, Faker::HarryPotter.quote) }
      14.times { create_post(simone, Faker::HarryPotter.quote) }
      3.times { create_post(bruno, Faker::HarryPotter.quote) }
      arthur.follow(dan)
      arthur.follow(simone)
    end

    before(:each) { get '/v1/timeline', headers: auth_headers }

    it 'gets posts just from followed users' do
      expect(response.status).to eq 200
      expect(data['data'].size).to eq 20
      # Check the user ids are only of those people followed.
      expect(data['data'].map { |post| post['relationships']['user']['data']['id'] }.uniq.sort).to eq [dan.id, simone.id].sort
    end

    it 'gets the most recent posts first' do
      expect(data['data'].first['id']).to eq Post.where(user_id: [dan.id, simone.id]).order('created_at desc').first.id
    end

    it 'paginates the posts' do
      next_page_expectations(total_posts: 22)
    end
  end
end
