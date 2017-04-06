class PostListSerializer < ActiveModel::Serializer
  attributes :id, :thumbnail_url, :caption, :created_at, :edited, :user

  def user
    UserListSerializer.new(object.user)
  end
end
