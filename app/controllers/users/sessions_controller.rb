class Users::SessionsController < DeviseTokenAuth::SessionsController
  include ErrorResource
  include TokenAuth
  skip_before_action :authenticate_user!, only: [:create]

  # Overriding https://github.com/lynndylanhurley/devise_token_auth/blob/v0.1.40/app/controllers/devise_token_auth/sessions_controller.rb
  # rubocop:disable all
  def create
    field = (resource_params.keys.map(&:to_sym) & resource_class.authentication_keys).first

    @resource = nil
    if field
      q_value = resource_params[field]

      if resource_class.case_insensitive_keys.include?(field)
        q_value.downcase!
      end

      # Overriding here so we can login with handles.
      @resource = resource_class.find_for_database_authentication(field => q_value)
    end

    if @resource && valid_params?(field, q_value) && (!@resource.respond_to?(:active_for_authentication?) || @resource.active_for_authentication?)
      valid_password = @resource.valid_password?(resource_params[:password])
      if (@resource.respond_to?(:valid_for_authentication?) && !@resource.valid_for_authentication? { valid_password }) || !valid_password
        render_create_error_bad_credentials
        return
      end

      # Overriding here to set created_at token time.
      create_auth(@resource)

      sign_in(:user, @resource, store: false, bypass: false)

      # Update devices if we have a player_id.
      Device.create_for_user(@resource, params[:player_id]) if params[:player_id].present?

      yield @resource if block_given?

      render_create_success
    elsif @resource && !(!@resource.respond_to?(:active_for_authentication?) || @resource.active_for_authentication?)
      render_create_error_not_confirmed
    else
      render_create_error_bad_credentials
    end
  end
  # rubocop:enable all

  protected

  def render_create_success
    render json: @resource
  end

  def render_create_error_bad_credentials
    render_error(I18n.t('devise_token_auth.sessions.bad_credentials'), 401)
  end

  def render_create_error_not_confirmed
    render_error(I18n.t('devise_token_auth.sessions.not_confirmed', email: @resource.email), 401)
  end

  def render_destroy_success
    head :no_content
  end

  def render_destroy_error
    render_error(I18n.t('devise_token_auth.sessions.user_not_found'), 404)
  end
end
