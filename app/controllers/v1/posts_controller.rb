class V1::PostsController < ApplicationController
  include ErrorResource
  include Pagination

  def index
    render json: posts.to_a.first(API_PAGE_SIZE),
           links: posts_links,
           meta: meta,
           include: :user,
           post_ids_in_window_liked_by_current_user: post_ids_in_window_liked_by_current_user
  end

  def show
    # This is the only method in this controller that allows access to posts by other users.
    show_post = Post.find_by(id: params[:id])

    if show_post.present?
      return render json: show_post,
                    serializer: PostFullSerializer,
                    include: :user,
                    post_ids_in_window_liked_by_current_user: post_ids_in_window_liked_by_current_user
    end

    render_error('Post not found', 404)
  end

  def create
    new_post = current_user.posts.create(create_permitted_params)

    if new_post.persisted?
      PushNotificationService::Post.new.call(new_post)

      return render json:
                    new_post,
                    serializer: PostFullSerializer,
                    post_ids_in_window_liked_by_current_user: [],
                    status: 201
    end

    render_validation_error(new_post)
  end

  def update
    return render_error('Post not found', 404) unless post.present?
    if post.update(update_permitted_params)
      return render json: post,
                    serializer: PostFullSerializer,
                    post_ids_in_window_liked_by_current_user: post_ids_in_window_liked_by_current_user,
                    status: 200
    end

    render_validation_error
  end

  def destroy
    return render_error('Post not found', 404) unless post.present?

    if post.destroy
      head :no_content
    else
      render_validation_error
    end
  end

  protected

  def render_validation_error(error_post = post)
    render json: error_post, serializer: ActiveModel::Serializer::ErrorSerializer, status: 422
  end

  def create_permitted_params
    params.require(:post).permit(:thumbnail_key,
                                 :original_key,
                                 :caption)
  end

  def update_permitted_params
    params.require(:post).permit(:caption)
  end

  def post
    @post ||= current_user.posts.find_by(id: params[:id])
  end

  def posts
    return @posts unless @posts.nil?

    # We try to get one more than the window size, to tell us if we need a next page link.
    @posts = current_user.posts.includes(:user)
    paginate(@posts)
    @posts.to_a
  end

  def posts_links
    return nil unless pagination_needed?
    {
      next: v1_posts_url(page: next_page_id)
    }
  end

  # Needed for pagination concern.
  def primary_records
    posts
  end

  def posts_ids
    return posts.map(&:id) if action_name == 'index'

    params[:id]
  end

  # Used to efficiently set the liked_by_me property of the post.
  def post_ids_in_window_liked_by_current_user
    @posts_in_window_liked_by_current_user ||= current_user.likes.where(post_id: posts_ids).map(&:post_id)
  end
end
