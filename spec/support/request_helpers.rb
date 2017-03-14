module RequestHelpers
  def fake_handle
    Fabricate.build('user').handle
  end

  def create_user_and_sign_in
    user = Fabricate.build(:user)

    post '/v1/users', params: {
      email: user.email,
      handle: user.handle,
      password: user.password,
      password_confirmation: user.password
    }

    post '/v1/users/sign_in', params: {
      login: user.email,
      password: user.password
    }
  end

  def auth_headers_from_response
    {
      client: response.headers['client'],
      'access-token': response.headers['access-token'],
      uid: response.headers['uid']
    }
  end
end
