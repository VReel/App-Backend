require 'rails_helper'

RSpec.describe 'Followers', type: :request do
  let!(:user) { create_user_and_sign_in }
  let(:other_user) { Fabricate(:user) }
  let(:data) { JSON.parse(response.body) if response.body.present? }
  let(:auth_headers) { auth_headers_from_response }

  describe 'a followed user appears in the list of following' do
    before(:each) { user.follow(other_user) }

    it 'appears in the list of followers' do
      get '/v1/following', headers: auth_headers

      expect(response.status).to eq 200
      expect(data['data'].size).to eq 1
      expect(data['data'].first['id']).to eq other_user.id
    end

    it 'does not appear in the list of followers' do
      get '/v1/followers', headers: auth_headers
      expect(response.status).to eq 200
      expect(data['data'].size).to eq 0
    end
  end

  describe 'a following user appears in the list of followers' do
    before(:each) { other_user.follow(user) }

    it 'appears in the list of followers' do
      get '/v1/followers', headers: auth_headers

      expect(response.status).to eq 200
      expect(data['data'].size).to eq 1
      expect(data['data'].first['id']).to eq other_user.id
    end

    it 'does not appear in the list of followers' do
      get '/v1/following', headers: auth_headers
      expect(response.status).to eq 200
      expect(data['data'].size).to eq 0
    end
  end

  describe 'pagination' do
    describe 'followers pagination' do
      before(:each) do
        25.times { Fabricate(:user).follow(user) }

        get '/v1/followers', headers: auth_headers
      end

      it 'gets a page of followers' do
        expect(response.status).to eq 200
        expect(data['data'].size).to eq 20
      end

      it 'gets the next page of followers' do
        next_page_expectations
      end
    end

    describe 'following pagination' do
      before(:each) do
        25.times { user.follow(Fabricate(:user)) }

        get '/v1/following', headers: auth_headers
      end

      it 'gets a page of followers' do
        expect(response.status).to eq 200
        expect(data['data'].size).to eq 20
      end

      it 'gets the next page of followers' do
        next_page_expectations
      end
    end

    # rubocop:disable Metrics/AbcSize
    def next_page_expectations
      expect(data['links']['next']).to be_present
      expect(data['meta']['next_page']).to be true
      expect(data['meta']['next_page_id']).to be_present

      get data['links']['next'], headers: auth_headers

      expect(response.status).to eq 200

      new_data = JSON.parse(response.body)

      expect(new_data['data'].size).to eq 5

      expect(new_data['links']).to be_nil
      expect(new_data['meta']['next_page']).to be false
    end
    # rubocop:enable Metrics/AbcSize
  end
end
