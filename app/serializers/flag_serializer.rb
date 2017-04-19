class FlagSerializer < ActiveModel::Serializer
  attributes :id, :reason

  has_one :user
  has_one :post
end
