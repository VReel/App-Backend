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

  def set_unique_fields
    # We are putting dummy values in these fields so the unique indexes
    # remain unique.
    # As far as rails is concerned, these records will not longer exist.
    user.email = "#{user.email}.#{rand(999_999_999_999_999)}.deleted"
    # Blank any fields with security issues
    user.password = nil
    user.tokens = nil
    user.save!
  end
end
