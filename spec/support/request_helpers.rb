module RequestHelpers
  def fake_handle
    Fabricate.build('user').handle
  end

  def client_application_header
    {
      'vreel-application-id' => AUTHORIZED_APPLICATION_IDS.first
    }
  end

  def fabricate_post_for(user)
    Fabricate(:post,
              user: user,
              thumbnail_key: "#{user.unique_id}/#{SecureRandom.random_number(36**12).to_s(36)}",
              original_key: "#{user.unique_id}/#{SecureRandom.random_number(36**12).to_s(36)}")
  end

  def create_user_and_sign_in(email = nil)
    user = Fabricate.build(:user)
    user.email = email if email.present?

    post '/v1/users', params: {
      email: user.email,
      handle: user.handle,
      password: user.password,
      password_confirmation: user.password
    }, headers: client_application_header

    post '/v1/users/sign_in', params: {
      login: user.email,
      password: user.password
    }, headers: client_application_header

    User.find_by(email: user.email)
  end

  def auth_headers_from_response
    {
      client: response.headers['client'],
      'access-token': response.headers['access-token'],
      uid: response.headers['uid']
    }.merge(client_application_header)
  end

  def create_post(user, caption = Faker::HarryPotter.quote)
    user.posts.create(
      original_key: "#{user.unique_id}/original",
      thumbnail_key: "#{user.unique_id}/thumbnail",
      caption: caption
    )
  end

  def more_than_a_page_count
    API_PAGE_SIZE + rand(API_PAGE_SIZE / 2) + 1
  end

  def first_page_expectations
    expect(response.status).to eq 200
    expect(data['data'].size).to eq API_PAGE_SIZE
  end

  def expect_page_id_to_match(page_id, record)
    expect(Base64.urlsafe_decode64(page_id)).to eq record.created_at.xmlschema(6)
  end

  # rubocop:disable Metrics/AbcSize
  def next_page_expectations(total: 25)
    expect(data['links']['next']).to be_present
    expect(data['meta']['next_page']).to be true
    expect(data['meta']['next_page_id']).to be_present

    get data['links']['next'], headers: auth_headers

    expect(response.status).to eq 200

    new_data = JSON.parse(response.body)

    expect(new_data['data'].size).to eq(total - API_PAGE_SIZE)

    expect(new_data['links']).to be_nil
    expect(new_data['meta']['next_page']).to be false
  end
  # rubocop:enable Metrics/AbcSize
end

RSpec::Matchers.define :one_signal_packet_with_player_ids do |player_ids|
  match { |packet| packet[:params][:include_player_ids].sort == player_ids.sort }
end
