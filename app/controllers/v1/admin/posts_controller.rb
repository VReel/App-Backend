class V1::Admin::PostsController < V1::PublicTimelineController
  include AdminPagination
  before_action :authenticate_chief!

  protected

  def posts
    return @posts unless @posts.nil?
    @posts = query.includes(:user)
    paginate(@posts)
    @posts
  end

  def posts_links
    return nil unless pagination_needed?
    {
      next: v1_admin_posts_url(page: next_page_id)
    }
  end

  def query
    Post.all.order(order_clause.join(' '))
  end

  def order_clause
    case params[:sort]
    when 'created_at_asc'
      %w(created_at ASC)
    when 'likes_asc'
      %w(like_count ASC)
    when 'likes_desc'
      %w(like_count DESC)
    when 'comments_asc'
      %w(comment_count ASC)
    when 'comments_desc'
      %w(comment_count DESC)
    else
      # The default option
      %w(created_at DESC)
    end
  end
end
