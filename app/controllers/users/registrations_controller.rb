class Users::RegistrationsController < DeviseTokenAuth::RegistrationsController
  include ErrorResource
  include TokenAuth
  skip_before_action :authenticate_user!, only: [:create]

  # Overriding https://github.com/lynndylanhurley/devise_token_auth/blob/v0.1.40/app/controllers/devise_token_auth/registrations_controller.rb
  # rubocop:disable all
  def create
    @resource            = resource_class.new(sign_up_params)
    @resource.provider   = "email"

    # honor devise configuration for case_insensitive_keys
    if resource_class.case_insensitive_keys.include?(:email)
      @resource.email = sign_up_params[:email].try :downcase
    else
      @resource.email = sign_up_params[:email]
    end

    @redirect_url = DeviseTokenAuth.default_confirm_success_url

    # success redirect url is required
    if resource_class.devise_modules.include?(:confirmable) && !@redirect_url
      return render_create_error_missing_confirm_success_url
    end

    begin
      # override email confirmation, must be sent manually from ctrl
      resource_class.set_callback("create", :after, :send_on_create_confirmation_instructions)
      resource_class.skip_callback("create", :after, :send_on_create_confirmation_instructions)
      if @resource.save
        yield @resource if block_given?

        unless @resource.confirmed?
          # user will require email authentication
          @resource.send_confirmation_instructions({
            client_config: params[:config_name],
            redirect_url: @redirect_url
          })

        end

        # Overridden - always authenticate user.
        create_auth(@resource)

        update_auth_header

        render_create_success
      else
        clean_up_passwords @resource
        render_create_error
      end
    rescue ActiveRecord::RecordNotUnique
      clean_up_passwords @resource
      render_create_error_email_already_exists
    end
  end
  # rubocop:enable all

  protected

  def render_create_success
    render json: @resource, status: 201
  end

  def render_create_error
    render json: @resource, serializer: ActiveModel::Serializer::ErrorSerializer, status: 422
  end

  def validate_post_data(which, message)
    render_error(message, 422) if which.empty?
  end

  def render_update_success
    render json: @resource, status: 200
  end

  def render_update_error
    render json: @resource, serializer: ActiveModel::Serializer::ErrorSerializer, status: 422
  end

  def render_destroy_success
    head :no_content
  end
end
