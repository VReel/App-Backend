class UserDeletionService
  attr_reader :user, :s3_deletion_service

  def initialize(user_id)
    # Don't instantiate here as you will confuse delayed job with a deleted model.
    @user_id = user_id
  end

  def user
    @user ||= User.with_deleted.find(@user_id)
  end

  def s3_deletion_service
    @s3_deletion_service ||= S3DeletionService.new
  end

  def delete!
    delete_user_model_assets
    delete_s3_assets
    delete_remaining_s3_assets
    delete_following_relationships
    delete_likes
    delete_comments
    delete_posts
    set_unique_fields
    Rails.logger.info "User #{user.id} assets and posts deleted"
  end

  def posts
    Post.where(user_id: user.id)
  end

  def delete_user_model_assets
    s3_deletion_service.delete(user.thumbnail_key) if user.thumbnail_key.present?
    s3_deletion_service.delete(user.original_key) if user.original_key.present?
  end

  def delete_s3_assets
    # S3 allows 1000 records at a time to be deleted.
    # So process 500 records, for 2 keys in each.
    posts.find_in_batches(batch_size: 500) do |posts|
      # Sorting the keys makes testing easier.
      keys = (posts.map(&:original_key) + posts.map(&:thumbnail_key)).sort
      s3_deletion_service.bulk_delete(keys)
    end
  end

  # We call this in case there is anything left in the folder.
  # This could be old profile images, or even things uploaded but never posted to the API.
  def delete_remaining_s3_assets
    # This gets up to 1000 objects.
    # If the user has over 1000 objects that were not in the database then there may be some assets remaining.
    keys = S3_BUCKET.objects(prefix: user.unique_id).map(&:key)

    s3_deletion_service.bulk_delete(keys)
  end

  def delete_posts
    posts.delete_all
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable SkipsModelValidations
  def delete_following_relationships
    # First store who we follow and are followed_by
    # I guess there's a scaling limit here.
    followed_users = user.following.select(:id, :created_at).to_a
    followed_by_users = user.followers.select(:id, :created_at).to_a
    # Delete the relationships
    user.following_relationships.delete_all(:delete_all)
    user.follower_relationships.delete_all(:delete_all)

    # Set the follower_counts of users who were being followed.
    followed_users.each do |followed_user|
      followed_user.update_columns(follower_count: followed_user.followers.count)
    end

    # Set the following_count of users who were following.
    followed_by_users.each do |followed_by_user|
      followed_by_user.update_columns(following_count: followed_by_user.following.count)
    end
  end
  # rubocop:enable SkipsModelValidations
  # rubocop:enable Metrics/AbcSize

  def delete_likes
    # Delete user's own likes.
    Like.where(user_id: user.id).delete_all
    # Delete likes on user's posts.
    Like.where('post_id IN (SELECT id FROM posts WHERE user_id = ?)', user.id).delete_all
  end

  def delete_comments
    # Delete user's own comments.
    Comment.where(user_id: user.id).delete_all
    # Delete comments on user's posts.
    Comment.where('post_id IN (SELECT id FROM posts WHERE user_id = ?)', user.id).delete_all
  end

  def set_unique_fields
    # We are putting dummy values in these fields so the unique indexes
    # remain unique.
    # As far as rails is concerned, these records will no longer exist.
    user.email = "#{user.email}.#{rand(999_999_999_999_999)}.deleted"
    # Blank any fields with security issues
    user.password = nil
    user.tokens = nil
    user.save!
  end
end
