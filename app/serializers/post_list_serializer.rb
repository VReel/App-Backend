class PostListSerializer < ActiveModel::Serializer
  attributes :id, :thumbnail_url, :caption, :created_at, :edited
end
