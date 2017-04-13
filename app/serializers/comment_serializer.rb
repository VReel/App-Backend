class CommentSerializer < ActiveModel::Serializer
  attributes :id, :text, :edited

  has_one :user
  has_one :post
end
