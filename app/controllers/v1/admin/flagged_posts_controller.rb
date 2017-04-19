class V1::Admin::FlaggedPostsController < V1::Admin::BaseController
  include ErrorResource
  include Pagination

  def index
    render json: posts.to_a.first(API_PAGE_SIZE),
           links: flagged_posts_links,
           meta: meta,
           include: :user,
           each_serializer: FlaggedPostSerializer,
           flag_counts: flag_counts
  end

  protected

  def posts
    @posts ||= paginate(Post.where(id: flag_counts.keys).order('created_at DESC').includes(:user))
  end

  def flag_counts
    @flag_counts ||= Flag.where(status: :awaiting).group(:post_id).count
  end

  def flagged_posts_links
    return nil unless pagination_needed?
    {
      next: v1_admin_flagged_posts_url(page: next_page_id)
    }
  end

  def primary_records
    posts
  end
end
