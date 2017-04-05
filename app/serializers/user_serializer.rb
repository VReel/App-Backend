class UserSerializer < ActiveModel::Serializer
  attributes :id, :handle, :name, :profile, :thumbnail_url, :original_url
  # Private data.
  attribute :email, if: :is_current_user?

  def is_current_user?
    object.id == current_user.id
  end
end
