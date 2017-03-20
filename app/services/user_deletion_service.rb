class UserDeletionService
  attr_reader :user

  # Initialize with a user_id as the user will no longer exist.
  def initialize(user_id)
    @user = User.with_deleted.find(user_id)
  end

  def delete!
    delete_s3_assets
    delete_posts
    set_unique_fields
    Rails.logger.info "User #{user.id} assets and posts deleted"
  end

  def posts
    Post.where(user_id: @user.id)
  end

  def delete_s3_assets
    service = S3DeletionService.new
    # S3 allows 1000 records at a time to be deleted.
    # So process 500 records, for 2 keys in each.
    posts.find_in_batches(batch_size: 500) do |posts|
      # Sorting the keys makes testing easier.
      keys = (posts.map(&:original_key) + posts.map(&:thumbnail_key)).sort
      service.bulk_delete(keys)
    end
  end

  def delete_posts
    posts.delete_all
  end

  def set_unique_fields
    # We are putting dummy values in these fields so the unique indexes
    # remain unique.
    # As far as rails is concerned, these records will not longer exist.
    user.email = "#{user.email}.#{rand(999_999_999_999_999)}.deleted"
    user.uid = rand(999_999_999_999_999)
    # Blank any fields with security issues
    user.password = nil
    user.tokens = nil
    user.save!
  end
end
