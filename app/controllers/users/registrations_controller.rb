class Users::RegistrationsController < DeviseTokenAuth::RegistrationsController
  include ErrorResource
  skip_before_action :authenticate_user!, only: [:create]

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
