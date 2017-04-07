class V1::PostHashTagsController < V1::PostsController
  def posts_with_hash_tag
    return render_error('Hash tag not found', 404) if hash_tag_id.blank?
    # We inherit pagination and meta links from posts controller.
    render json: posts.first(API_PAGE_SIZE), links: posts_links, meta: meta, include: :user
  end

  protected

  # rubocop:disable Metrics/AbcSize
  def posts
    return @posts unless @posts.nil?

    hash_tag_posts = HashTagPost.where(hash_tag_id: hash_tag_id).order('created_at DESC').includes(post: :user)
    hash_tag_posts.limit!(API_PAGE_SIZE + 1)
    hash_tag_posts.where!('created_at < ?', Time.zone.parse(Base64.urlsafe_decode64(params[:page]))) if params[:page].present?

    @posts = hash_tag_posts.map(&:post)
  end
  # rubocop:enable Metrics/AbcSize

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
