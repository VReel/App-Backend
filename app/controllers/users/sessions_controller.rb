class Users::SessionsController < DeviseTokenAuth::SessionsController
  include ErrorResource
  skip_before_action :authenticate_user!, only: [:create]

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
