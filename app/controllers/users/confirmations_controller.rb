class Users::ConfirmationsController < DeviseTokenAuth::ConfirmationsController
  include ErrorResource
  skip_before_action :authenticate_user!, only: [:create, :show]
  skip_before_action :authenticate_application!, only: :show

  def create
    user = User.find_for_database_authentication(email: params[:email])
    if user
      if user.confirmed?
        render_error(I18n.t('errors.messages.already_confirmed'), 405)
      else
        user.send_confirmation_instructions
        head :no_content
      end
    else
      render_error(I18n.t('errors.messages.not_found'), 404)
    end
  end
end
