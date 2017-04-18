class PostSerializer < ActiveModel::Serializer
  attributes :id, :thumbnail_url, :caption, :like_count, :comment_count, :created_at, :edited, :liked_by_me

  has_one :user

  def liked_by_me
    instance_options[:post_ids_in_window_liked_by_current_user].include?(object.id)
  end
end
