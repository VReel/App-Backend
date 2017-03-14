class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!

  protected

  def configure_permitted_parameters
    added_attrs = [:handle, :email, :password, :password_confirmation]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
  end

  # This overrides https://github.com/dansingerman/devise_token_auth/blob/master/app/controllers/devise_token_auth/concerns/set_user_by_token.rb
  def update_auth_header
    # cannot save object if model has invalid params
    return unless @resource && @resource.valid? && @client_id

    # Generate new client_id with existing authentication
    @client_id = nil unless @used_auth_by_token

    if @used_auth_by_token &&
      current_user &&
      ENV['ACCESS_TOKEN_LIFETIME'].present? &&
      @request_started_at < current_user.updated_at + Integer(ENV['ACCESS_TOKEN_LIFETIME'])
      return response.headers.merge!(current_user.build_auth_header(@token, @client_id))
    end

    super
  end
end
