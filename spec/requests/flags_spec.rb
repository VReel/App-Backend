require 'rails_helper'

RSpec.describe 'Flag requests', type: :request do
  let!(:user) { create_user_and_sign_in }
  let(:data) { JSON.parse(response.body) }
  let(:existing_post) { fabricate_post_for(Fabricate(:user)) }
  let(:auth_headers) { auth_headers_from_response }
  before(:each) { ENV['MODERATOR_EMAILS'] = "#{Faker::Internet.email}, #{Faker::Internet.email}"}

  describe 'flag a post' do
    it 'succeeds when valid' do
      expect do
        post "/v1/posts/#{existing_post.id}/flags", params: {
          flag: { reason: Faker::HarryPotter.quote }
        }, headers: auth_headers
      end.to change { Flag.count }.by 1

      expect(response.status).to eq 204
    end

    it 'fails when post is not found' do
      post "/v1/posts/#{SecureRandom.uuid}/flags", params: {
        flag: { reason: Faker::HarryPotter.quote }
      }, headers: auth_headers

      expect(response.status).to eq 404
    end

    it 'sends an email to the moderators' do
      expect do
        post "/v1/posts/#{existing_post.id}/flags", params: {
          flag: { reason: Faker::HarryPotter.quote }
        }, headers: auth_headers
      end.to change { ActionMailer::Base.deliveries.size }.by(1)

      expect(ActionMailer::Base.deliveries.last['to'].to_s).to eq ENV['MODERATOR_EMAILS']
      expect(ActionMailer::Base.deliveries.last['subject'].to_s).to include 'flagged'
    end
  end
end
