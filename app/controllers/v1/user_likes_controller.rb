class V1::UserLikesController < V1::PostsController
  protected

  def posts
    @posts ||= likes.map(&:post)
  end

  def likes
    @likes ||= paginate(Like.where(user_id: params[:user_id]).order('created_at DESC').includes(:user))
  end

  def posts_links
    return nil unless pagination_needed?
    {
      next: v1_user_likes_url(page: next_page_id)
    }
  end
end
