require 'rails_helper'

RSpec.describe 'Admin Flag requests', type: :request do
  let!(:user) { create_user_and_sign_in('dan@reasonfactory.com') }
  let(:data) { JSON.parse(response.body) }
  let(:auth_headers) { auth_headers_from_response }
  before(:each) { ENV['MODERATOR_EMAILS'] = "#{Faker::Internet.email}, #{Faker::Internet.email}" }
  let(:random_number) { rand(5) + 1 }

  describe 'Get a list of flagged posts' do
    before(:each) do
      random_number.times do
        create_post(Fabricate(:user)).flags.create(reason: Faker::HarryPotter.quote, user: Fabricate(:user))
      end
    end

    it 'Gets the flagged posts' do
      get '/v1/admin/flagged_posts', headers: auth_headers

      expect(response.status).to eq 200
      expect(data['data'].size).to eq random_number
    end
  end

  describe 'Get the flags on a post' do
    let!(:post_author) { Fabricate(:user) }
    let!(:flag_author) { Fabricate(:user) }
    let(:flagged_post) { create_post(post_author) }

    before(:each) do
      random_number.times do
        flagged_post.flags.create(reason: Faker::HarryPotter.quote, user: flag_author)
      end

      get "/v1/admin/flagged_posts/#{flagged_post.id}/flags", headers: auth_headers
    end

    it 'Gets the flags' do
      expect(response.status).to eq 200
      expect(data['data'].size).to eq random_number
    end

    it 'Gets the authors of the flagged posts' do
      expect(data['included'].map { |item| item['id'] }).to include post_author.id
    end

    it 'Gets the users who created the flags' do
      expect(data['included'].map { |item| item['id'] }).to include flag_author.id
    end
  end

end
