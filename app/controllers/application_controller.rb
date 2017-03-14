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
  # rubocop:disable all
  def update_auth_header
    # cannot save object if model has invalid params
    # @resource should == current_user
    return unless @resource && @resource.valid? && @client_id

    # Generate new client_id with existing authentication
    @client_id = nil unless @used_auth_by_token

    if @used_auth_by_token &&
       @resource.try(:tokens).present? &&
       ENV['ACCESS_TOKEN_LIFETIME'].present?

      # should not append auth header if @resource related token was
      # cleared by sign out in the meantime.
      return if @resource.reload.tokens[@client_id].nil?

      if @request_started_at < @resource.token_created_at(@client_id) + Integer(ENV['ACCESS_TOKEN_LIFETIME'])
        return response.headers.merge!(@resource.build_auth_header(@token, @client_id))
      end
    end

    super
  end
  # rubocop:enable all
end
