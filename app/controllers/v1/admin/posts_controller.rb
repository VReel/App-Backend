class V1::Admin::PostsController < V1::PublicTimelineController
  before_action :authenticate_chief!

  protected

  def paginate(query)
    query.limit!(API_PAGE_SIZE + 1)
    query.offset!(Integer(params[:page] || 0) * API_PAGE_SIZE)
    query
  end

  def posts
    return @posts unless @posts.nil?
    @posts = query.includes(:user)
    paginate(@posts)
    @posts
  end

  def next_page_id
    @next_page_id ||= params[:page].present? ? Integer(params[:page]) : 1
  end

  def meta
    super.merge(total: query.dup.count)
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
    when nil, '', 'created_at_desc'
      %w(created_at DESC)
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
      raise 'Unsupported sort param'
    end
  end
end
