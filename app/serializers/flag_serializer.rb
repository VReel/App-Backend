class FlagSerializer < ActiveModel::Serializer
  def self.serializer_for(model, options)
    return FlaggedPostSerializer if model.class.to_s == 'Post'
    super
  end

  attributes :id, :reason

  has_one :user
  has_one :post
end
