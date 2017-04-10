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

  def create_post(user, caption)
    user.posts.create(
      original_key: "#{user.unique_id}/original",
      thumbnail_key: "#{user.unique_id}/thumbnail",
      caption: caption
    )
  end

  # rubocop:disable Metrics/AbcSize
  def next_page_expectations(total_posts: 25)
    expect(data['links']['next']).to be_present
    expect(data['meta']['next_page']).to be true
    expect(data['meta']['next_page_id']).to be_present

    get data['links']['next'], headers: auth_headers

    expect(response.status).to eq 200

    new_data = JSON.parse(response.body)

    expect(new_data['data'].size).to eq(total_posts - 20)

    expect(new_data['links']).to be_nil
    expect(new_data['meta']['next_page']).to be false
  end
  # rubocop:enable Metrics/AbcSize
end
