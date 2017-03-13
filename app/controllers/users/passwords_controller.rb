class Users::PasswordsController < DeviseTokenAuth::PasswordsController
  include ErrorResource
  skip_before_action :authenticate_user!
  before_action :hash_email, only: [:create]

  protected

  def hash_email
    params[:email] = User.hash_to_uid(params[:email]) if params[:email].present?
  end

  def render_create_error
    render_error(I18n.t('errors.messages.not_found'), 404)
  end
end
