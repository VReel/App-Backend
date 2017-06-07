class V1::Admin::PostsController < V1::Admin::BaseController
  include AdminPagination

  def index
    render json: posts.to_a.first(API_PAGE_SIZE),
           links: posts_links,
           meta: meta,
           include: :user
  end

  protected

  def primary_records
    posts
  end

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

  # rubocop:disable all
  def query
    q = Post.all
    q.where!('posts.created_at >= ?', Time.zone.parse(params[:date_from]).beginning_of_day) if params[:date_from].present?
    q.where!('posts.created_at <= ?', Time.zone.parse(params[:date_to]).end_of_day) if params[:date_to].present?
    q.where!('posts.user_id IN (SELECT id FROM users WHERE handle ilike(?))', params[:user]) if params[:user].present?
    q.where!('posts.like_count >= ?', params[:min_likes].to_i) if params[:min_likes].present?
    q.where!('posts.like_count <= ?', params[:max_likes].to_i) if params[:max_likes].present?
    q.where!('posts.comment_count >= ?', params[:min_comments].to_i) if params[:min_comments].present?
    q.where!('posts.comment_count <= ?', params[:max_comments].to_i) if params[:max_comments].present?
    q.order(order_clause)
  end
  # rubocop:enable all

  def order_clause
    case params[:sort]
    when 'created_at_asc'
      'created_at ASC'
    when 'likes_asc'
      'like_count ASC'
    when 'likes_desc'
      'like_count DESC'
    when 'comments_asc'
      'comment_count ASC'
    when 'comments_desc'
      'comment_count DESC'
    else
      # The default option
      'created_at DESC'
    end
  end
end
