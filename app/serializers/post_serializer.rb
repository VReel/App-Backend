class PostSerializer < ActiveModel::Serializer
  attributes :id, :thumbnail_url, :caption, :created_at, :edited

  has_one :user
end
