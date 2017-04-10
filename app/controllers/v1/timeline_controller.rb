class V1::TimelineController < V1::PostsController
  protected

  def posts
    return @posts unless @posts.nil?
    @posts = Post.where('user_id IN (SELECT following_id FROM follows WHERE follower_id = ?)', current_user.id)
    # Alternatives. Join version not working yet.
    # @posts = Post.joins(user: :following_relationships).where('follows.following_id = ? ', current_user.id)
    # @posts = Post.where(user_id: current_user.following_relationships.map(&:following_id))
    @posts = @posts.order('created_at DESC').includes(:user)
    paginate(@posts)
    @posts
  end

  def posts_links
    return nil unless pagination_needed?
    {
      next: v1_timeline_url(page: next_page_id)
    }
  end
end
