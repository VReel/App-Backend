class Users::PasswordsController < DeviseTokenAuth::PasswordsController
  include ErrorResource
  skip_before_action :authenticate_user!
  skip_before_action :authenticate_application!, only: :edit
  before_action :hash_email, only: [:create]

  # Overriding as we will create a new password and send it by email.
  def edit
    @resource = resource_class.reset_password_by_token({
      reset_password_token: resource_params[:reset_password_token]
    })

    if @resource && @resource.id
      password = generate_reset_password

      @resource.update(password: password, password_confirmation: password)
      @resource.confirm unless @resource.confirmed?

      redirect_to(@resource.build_auth_url(params[:redirect_url], {}))
    else
      render_edit_error
    end
  end

  protected

  def render_create_error_missing_email

  end

  def render_create_success
    render json: {
      data: {
        type: 'message',
        attributes: {
          content: I18n.t("devise_token_auth.passwords.sended", email: @original_email)
        }
      }
    }
  end

  def render_edit_error

  end

  # https://github.com/lynndylanhurley/devise_token_auth/blob/master/app/controllers/devise_token_auth/passwords_controller.rb
  # assumes that uid is the email.
  # We don't want to assume that.
  def hash_email
    @original_email = params[:email]
    params[:email] = User.hash_to_uid(params[:email]) if params[:email].present?
  end

  def render_create_error
    render_error(I18n.t('errors.messages.not_found'), 404)
  end

  def generate_reset_password
    SecureRandom.random_number(36**12).to_s(36)
  end
end
