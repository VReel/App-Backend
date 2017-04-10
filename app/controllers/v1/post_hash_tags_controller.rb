class V1::PostHashTagsController < V1::PostsController
  def index
    return render_error('Hash tag not found', 404) if hash_tag_id.blank?
    # We inherit pagination and meta links from posts controller.
    super
  end

  protected

  def posts
    return @posts unless @posts.nil?

    hash_tag_posts = HashTagPost.where(hash_tag_id: hash_tag_id).order('created_at DESC').includes(post: :user)
    paginate(hash_tag_posts)

    @posts = hash_tag_posts.map(&:post)
  end

  def hash_tag_id
    # if the hash_tag does not start with a #, assume it is a uuid.
    @hash_tag_id ||= if params[:hash_tag].first == '#'
                       HashTag.find_with_tag(params[:hash_tag]).try(:id)
                     else
                       params[:hash_tag]
                     end
  end

  def posts_links
    return nil unless pagination_needed?
    {
      next: v1_post_hash_tags_url(hash_tag: params[:hash_tag], page: next_page_id)
    }
  end
end
