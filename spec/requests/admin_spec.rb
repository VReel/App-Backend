require 'rails_helper'

RSpec.describe 'Admin', type: :request do
  let(:sign_in_chief) { create_user_and_sign_in('dan@reasonfactory.com') }
  let(:sign_in_not_chief) { create_user_and_sign_in }
  let(:data) { JSON.parse(response.body) }
  let(:auth_headers) { auth_headers_from_response }

  describe 'Authorisation' do
    it 'Chiefs can access paths under admin' do
      sign_in_chief
      get '/v1/admin/stats', headers: auth_headers_from_response
      expect(response.status).to eq 200
    end

    it 'Other can not access paths under admin' do
      sign_in_not_chief
      get '/v1/admin/stats', headers: auth_headers_from_response
      expect(response.status).to eq 401
    end
  end

  describe 'posts' do
    let(:user) { Fabricate(:user) }

    describe 'chiefs' do
      let(:total_posts) { more_than_a_page_count }

      before(:each) do
        total_posts.times { fabricate_post_for(user) }

        sign_in_chief

        get '/v1/admin/posts', headers: auth_headers
      end

      it 'gets a page of posts' do
        first_page_expectations
      end

      it 'gets the next page of posts' do
        next_page_expectations(total: total_posts)
      end
    end

    describe 'not chief' do
      before(:each) do
        fabricate_post_for(user)

        sign_in_not_chief

        get '/v1/admin/posts', headers: auth_headers
      end

      it 'can not access' do
        expect(response.status).to eq 401
      end
    end
  end

  describe 'users' do
    let(:user) { Fabricate(:user) }

    describe 'chiefs' do
      let(:total_users) { more_than_a_page_count }

      before(:each) do
        total_users.times { Fabricate(:user) }

        sign_in_chief

        get '/v1/admin/users', headers: auth_headers
      end

      it 'gets a page of users' do
        first_page_expectations
      end

      it 'gets the next page of users' do
        # We have plus one because the current user will also be returned.
        next_page_expectations(total: total_users + 1)
      end
    end

    describe 'not chief' do
      before(:each) do
        Fabricate(:user)

        sign_in_not_chief

        get '/v1/admin/users', headers: auth_headers
      end

      it 'can not access' do
        expect(response.status).to eq 401
      end
    end
  end
end
