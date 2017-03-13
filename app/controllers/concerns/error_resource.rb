module ErrorResource
  extend ActiveSupport::Concern

  protected

  def render_error(message, status, field = :base)
    error_resource = User.new
    error_resource.errors.add(field, message)
    render json: error_resource, serializer: ActiveModel::Serializer::ErrorSerializer, status: status
  end
end
