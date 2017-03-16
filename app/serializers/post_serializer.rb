class PostSerializer < ActiveModel::Serializer
  attributes :id, :original_url, :caption
end
