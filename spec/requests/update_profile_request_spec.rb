require 'rails_helper'

RSpec.describe 'Update profile requests', type: :request do
  let(:password) { 'I_liek_ham!' }
  let(:confirmed_user) do
    user = Fabricate(:user, password: password, password_confirmation: password)
    user.skip_confirmation!
    user.save
    user
  end
  let(:auth_headers) { response.headers.slice('access-token', 'client', 'uid').merge(client_application_header) }
  let(:name) { Faker::Name.name }
  let(:profile) { Faker::Lorem.sentence }
  let(:data) { JSON.parse(response.body) if response.body.present? }

  before(:each) do
    post '/v1/users/sign_in', params: {
      login: confirmed_user.email,
      password: password
    }, headers: client_application_header
  end

  describe 'Update profile attributes' do
    it 'can update attributes' do
      patch '/v1/users', headers: auth_headers, params: { handle: 'a_new_handle' }
      expect(response.status).to eq 200
      confirmed_user.reload
      expect(confirmed_user.handle).to eq 'a_new_handle'
    end

    it 'can update profile and name' do
      patch '/v1/users', headers: auth_headers, params: {
        profile: profile,
        name: name
      }

      expect(response.status).to eq 200
      confirmed_user.reload

      expect(confirmed_user.profile).to eq profile
      expect(confirmed_user.name).to eq name
    end

    it 'cannot update email' do
      old_email = confirmed_user.email

      patch '/v1/users', headers: auth_headers, params: {
        email: Faker::Internet.email,
        name: name
      }

      confirmed_user.reload

      # Email is unchanged.
      expect(confirmed_user.email).to eq old_email
      # Other fields are changed.
      expect(confirmed_user.name).to eq name
    end

    it 'All attributes are returned' do
      patch '/v1/users', headers: auth_headers, params: {
        profile: profile,
        name: name
      }

      expect(data['data']['attributes']['name']).to be_present
      expect(data['data']['attributes']['profile']).to be_present
    end
  end

  describe 'Update password' do
    it 'Cannot update password without a confirmation' do
      patch '/v1/users', headers: auth_headers, params: {
        password: 'a_new_password',
        current_password: password
      }
      expect(response.status).to eq 422
      confirmed_user.reload
      expect(confirmed_user.valid_password?('a_new_password')).to be false
    end

    it 'Cannot update password without a current_password' do
      patch '/v1/users', headers: auth_headers, params: {
        password: 'a_new_password_2',
        password_confirmation: 'a_new_password_2'
      }
      expect(response.status).to eq 422
      confirmed_user.reload
      expect(confirmed_user.valid_password?('a_new_password_2')).to be false
    end

    it 'Can update password with a confirmation and a current password' do
      patch '/v1/users', headers: auth_headers, params: {
        password: 'a_new_password_3',
        password_confirmation: 'a_new_password_3',
        current_password: password
      }
      expect(response.status).to eq 200
      confirmed_user.reload
      expect(confirmed_user.valid_password?('a_new_password_3')).to be true
    end
  end

  describe 'update s3 assets' do
    let(:thumbnail_key) { "#{confirmed_user.unique_id}/some_thumbnail_key" }
    let(:original_key) { "#{confirmed_user.unique_id}/some_original_key" }

    it 'must have a thumbnail_key if it has an original_key' do
      patch '/v1/users', headers: auth_headers, params: {
        original_key: 'some_new_key'
      }
      expect(response.status).to eq 422
      expect(data['errors'].first['source']['pointer']).to eq '/data/attributes/thumbnail_key'
    end

    it 'must have an original_key if it has an thumbnail_key' do
      patch '/v1/users', headers: auth_headers, params: {
        thumbnail_key: 'some_new_key'
      }
      expect(response.status).to eq 422
      expect(data['errors'].first['source']['pointer']).to eq '/data/attributes/original_key'
    end

    it 'keys must be prefixed with the user unique id' do
      patch '/v1/users', headers: auth_headers, params: {
        thumbnail_key: 'some_new_key',
        original_key: 'some_other_new_key'
      }
      expect(response.status).to eq 422
      expect(data['errors'].first['source']['pointer']).to eq '/data/attributes/original_key'
      expect(data['errors'].second['source']['pointer']).to eq '/data/attributes/thumbnail_key'
    end

    it 'can update keys' do
      patch '/v1/users', headers: auth_headers, params: {
        thumbnail_key: thumbnail_key,
        original_key: original_key
      }
      expect(response.status).to eq 200

      expect(data['data']['attributes']['thumbnail_url']).to be_present
      expect(data['data']['attributes']['original_url']).to be_present

      confirmed_user.reload

      expect(confirmed_user.thumbnail_key).to eq thumbnail_key
      expect(confirmed_user.original_key).to eq original_key
    end

    describe 'updating keys in pairs' do
      before(:each) { confirmed_user.update(thumbnail_key: thumbnail_key, original_key: original_key) }

      it 'must update original_key if it updates the thumbnail_key' do
        patch '/v1/users', headers: auth_headers, params: {
          thumbnail_key: "#{thumbnail_key}-updated"
        }

        expect(response.status).to eq 422
        expect(data['errors'].first['source']['pointer']).to eq '/data/attributes/original_key'
      end

      it 'must update thumbnail_key if it updates the original_key' do
        patch '/v1/users', headers: auth_headers, params: {
          original_key: "#{original_key}-updated"
        }

        expect(response.status).to eq 422
        expect(data['errors'].first['source']['pointer']).to eq '/data/attributes/thumbnail_key'
      end
    end
  end
end
