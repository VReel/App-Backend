class UserFullSerializer < UserSerializer
  attributes :id, :handle, :name, :profile, :thumbnail_url, :original_url, :follower_count, :following_count, :post_count

  # Private data.
  attribute :email, if: :is_current_user?
end
