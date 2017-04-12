class PostSerializer < ActiveModel::Serializer
  attributes :id, :thumbnail_url, :caption, :like_count, :comment_count, :created_at, :edited

  has_one :user
end
