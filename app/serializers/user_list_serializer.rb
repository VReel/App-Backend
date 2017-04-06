class UserListSerializer < ActiveModel::Serializer
  attributes :id, :handle, :name, :thumbnail_url, :follower_count, :following_count, :post_count
  # Private data.
  attribute :email, if: :is_current_user?

  def is_current_user?
    return false unless defined? current_user

    object.id == current_user.id
  end
end
