class V1::OtherUserPostsController < V1::PostsController
  prepend_before_action :allow_guest_access!, only: :index

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
    @user ||= User.find_by(id: params[:user_id])
  end

  def posts_links
    return nil unless pagination_needed?
    {
      next: v1_user_posts_url(user_id: params[:user_id], page: next_page_id)
    }
  end
end
