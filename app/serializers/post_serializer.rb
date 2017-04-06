class PostSerializer < PostListSerializer
  attributes :id, :thumbnail_url, :original_url, :caption, :created_at, :edited, :user
end
