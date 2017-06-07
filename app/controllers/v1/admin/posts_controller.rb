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

  # rubocop:disable all
  def query
    q = Post.all
    q.where!('posts.created_at >= ?', Time.zone.parse(params[:date_from]).beginning_of_day) if params[:date_from].present?
    q.where!('posts.created_at <= ?', Time.zone.parse(params[:date_to]).end_of_day) if params[:date_to].present?
    q.where!('posts.user_id IN (SELECT id FROM users WHERE handle = ?)', params[:user]) if params[:user].present?
    q.where!('posts.like_count >= ?', params[:min_likes].to_i) if params[:min_likes].present?
    q.where!('posts.like_count <= ?', params[:max_likes].to_i) if params[:max_likes].present?
    q.where!('posts.comment_count >= ?', params[:min_comments].to_i) if params[:min_comments].present?
    q.where!('posts.comment_count <= ?', params[:max_comments].to_i) if params[:max_comments].present?
    q.order(order_clause.join(' '))
  end
  # rubocop:enable all

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
