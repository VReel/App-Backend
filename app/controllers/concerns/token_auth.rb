module TokenAuth
  extend ActiveSupport::Concern

  def create_auth(resource)
    # create client id
    @client_id = SecureRandom.urlsafe_base64(nil, false)
    @token     = SecureRandom.urlsafe_base64(nil, false)

    now = Time.zone.now
    resource.tokens[@client_id] = {
      token: BCrypt::Password.create(@token),
      expiry: (now + DeviseTokenAuth.token_lifespan).to_i,
      created_at: now.to_i
    }
    resource.save!
  end
end
