class UserAdminSerializer < UserSerializer
  attributes :id, :handle, :name, :profile, :thumbnail_url, :original_url, :follower_count, :following_count, :post_count, :email, :created_at
end
