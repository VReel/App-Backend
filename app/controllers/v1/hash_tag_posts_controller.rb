class V1::HashTagPostsController < V1::PostsController
  prepend_before_action :allow_guest_access!, only: :index

  def index
    return render_error('Hash tag not found', 404) if hash_tag_id.blank?
    # We inherit pagination and meta links from posts controller.
    super
  end

  protected

  def posts
    @posts ||= hash_tag_posts.map(&:post)
  end

  def hash_tag_posts
    @hash_tag_posts ||= paginate(HashTagPost.where(hash_tag_id: hash_tag_id).order('created_at DESC').includes(post: :user))
  end

  def hash_tag_id
    # if the hash_tag does not start with a #, assume it is a uuid.
    @hash_tag_id ||= if params[:hash_tag_id].first == '#'
                       HashTag.find_with_tag(params[:hash_tag_id]).try(:id)
                     else
                       params[:hash_tag_id]
                     end
  end

  def posts_links
    return nil unless pagination_needed?
    {
      next: v1_hash_tag_posts_url(hash_tag_id: params[:hash_tag_id], page: next_page_id)
    }
  end

  def primary_records
    hash_tag_posts
  end
end
