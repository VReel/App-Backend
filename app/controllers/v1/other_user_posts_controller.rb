class V1::OtherUserPostsController < V1::PostsController
  def index
    return render_error('User not found', 404) if user.blank?
    # We inherit pagination and meta links from posts controller.
    super
  end

  protected

  def posts
    @posts ||= paginate(user.posts.includes(:user))
  end

  def user
    # if the hash_tag does not start with a #, assume it is a uuid.
    @user = User.find_by(id: params[:user_id])
  end

  def posts_links
    return nil unless pagination_needed?
    {
      next: v1_user_posts_url(user_id: params[:user_id], page: next_page_id)
    }
  end
end
