module RequestHelpers
  def fake_handle
    Fabricate.build('user').handle
  end

  def client_application_header
    {
      'vreel-application-id' => AUTHORIZED_APPLICATION_IDS.first
    }
  end

  def create_user_and_sign_in
    user = Fabricate.build(:user)

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

    User.find_by_email(user.email)
  end

  def auth_headers_from_response
    {
      client: response.headers['client'],
      'access-token': response.headers['access-token'],
      uid: response.headers['uid']
    }.merge(client_application_header)
  end
end
