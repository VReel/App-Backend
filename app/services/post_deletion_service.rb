class PostDeletionService
  attr_reader :post

  def initialize(post_id)
    # Don't instantiate here as you will confuse delayed job with a deleted model.
    @post_id = post_id
  end

  def post
    @post ||= Post.with_deleted.find(@post_id)
  end

  # rubocop:disable SkipsModelValidations
  def delete!
    post.delete_s3_resources
    post.remove_hash_tags(post.hash_tag_values)
    post.comments.delete_all(:delete_all)
    post.likes.delete_all(:delete_all)
    post.flags.update_all(status: :post_deleted)
  end
  # rubocop:enable SkipsModelValidations
end
