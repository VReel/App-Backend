class UserFullSerializer < UserSerializer
  attributes :id, :handle, :name, :profile, :thumbnail_url, :original_url, :follower_count, :following_count, :post_count

  attribute :follows_me, if: :follower_ids_present?
  attribute :followed_by_me, if: :following_ids_present?

  # Private data.
  attribute :email, if: :is_current_user?

  def follower_ids_present?
    !instance_options[:follower_ids].nil?
  end

  def following_ids_present?
    !instance_options[:following_ids].nil?
  end

  def follows_me
    instance_options[:follower_ids].include?(object.id)
  end

  def followed_by_me
    instance_options[:following_ids].include?(object.id)
  end
end
