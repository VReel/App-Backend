class UserSerializer < ActiveModel::Serializer
  attributes :id, :handle, :name, :thumbnail_url, :follower_count, :following_count, :post_count
  # Private data.
  attribute :email, if: :is_current_user?
  attribute :follows_me, if: :follower_ids_present?
  attribute :followed_by_me, if: :following_ids_present?

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

  def is_current_user?
    return false unless defined? current_user
    return false if current_user.blank?

    object.id == current_user.id
  end
end
