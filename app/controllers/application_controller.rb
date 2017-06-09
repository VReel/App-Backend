class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_application!
  before_action :authenticate_user!

  protected

  def authenticate_chief!
    return if current_user.try(:is_chief?)

    render json: {
      errors: ['Chiefs only.']
    }, status: 401
  end

  def authenticate_application!
    return if ClientApplication.request_valid?(request)

    render json: {
      errors: ['Authorized applications only.']
    }, status: 401
  end

  def configure_permitted_parameters
    sign_up_attrs = [:handle, :email, :password, :password_confirmation, :name, :profile]
    account_update_attrs = (sign_up_attrs + [:thumbnail_key, :original_key]) - [:email]
    devise_parameter_sanitizer.permit :sign_up, keys: sign_up_attrs
    # We don't allow email to be changed.
    devise_parameter_sanitizer.permit :account_update, keys: account_update_attrs
  end

  # This overrides https://github.com/lynndylanhurley/devise_token_auth/blob/v0.1.40/app/controllers/devise_token_auth/concerns/set_user_by_token.rb
  # This is so we can set the lifetime of the access token, and not have to change it on every single request.
  # This is good for performance, and makes the API much easier to use via swagger.
  # Changing on every request seems like an unnecessary overhead.
  # rubocop:disable all
  def update_auth_header
    # cannot save object if model has invalid params
    # @resource should == current_user
    return unless @resource && @resource.valid? && @client_id

    # Generate new client_id with existing authentication
    @client_id = nil unless @used_auth_by_token

    if @used_auth_by_token &&
       @resource.try(:tokens).present? &&
       ENV['ACCESS_TOKEN_LIFETIME'].to_i > 0

      # Get the token we are working with before reload (a simultaneous request could alter the valid token)
      original_token = @resource.tokens[@client_id].try(:fetch, 'token')

      @resource.reload

      # should not append auth header if @resource related token was
      # cleared by sign out in the meantime.
      return if @resource.tokens[@client_id].nil?

      token_created_at = Time.zone.at(@resource.tokens[@client_id]['created_at'])

      # If the token has not expired or changed and this is not a batch request, return it as a valid token.
      if @request_started_at < token_created_at + Integer(ENV['ACCESS_TOKEN_LIFETIME']) &&
           original_token == @resource.tokens[@client_id]['token'] &&
           !is_batch_request?(@resource, @client_id)

        return response.headers.merge!(@resource.build_auth_header(@token, @client_id))
      end
    end

    super
  end
  # rubocop:enable all
end
