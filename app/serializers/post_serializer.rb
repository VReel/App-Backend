class PostSerializer < ActiveModel::Serializer
  attributes :id, :thumbnail_url, :original_url, :caption
end
