class HashTagSerializer < ActiveModel::Serializer
  attributes :tag

  def tag
    object.tag_with_hash
  end
end
