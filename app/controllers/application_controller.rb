class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_user!
  before_action :authenticate_application!

  protected

  def authenticate_application!
    # We don't need to authenticate the application if there is auser authenticated by token.
    return if current_user.present?

    unless ClientApplication.request_valid?(request)
      return render json: {
        errors: ["Authorized applications only."]
      }, status: 401
    end
  end

  def configure_permitted_parameters
    added_attrs = [:handle, :email, :password, :password_confirmation]
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
    devise_parameter_sanitizer.permit :account_update, keys: added_attrs
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
       ENV['ACCESS_TOKEN_LIFETIME'].present? &&
       Integer(ENV['ACCESS_TOKEN_LIFETIME']).to_i > 0

      # should not append auth header if @resource related token was
      # cleared by sign out in the meantime.
      return if @resource.reload.tokens[@client_id].nil?

      if @request_started_at < Time.zone.at(@resource.tokens[@client_id]['created_at'])+ Integer(ENV['ACCESS_TOKEN_LIFETIME'])
        return response.headers.merge!(@resource.build_auth_header(@token, @client_id))
      end
    end

    super
  end
  # rubocop:enable all
end
