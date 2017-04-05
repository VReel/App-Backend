class V1::PostsController < ApplicationController
  include ErrorResource

  def index
    render json: posts.first(API_PAGE_SIZE), each_serializer: PostListSerializer, links: posts_links, meta: meta
  end

  def show
    return render json: post, status: 200 if post.present?

    render_error('Post not found', 404)
  end

  def create
    new_post = current_user.posts.create(create_permitted_params)

    return render json: new_post, status: 201 if new_post.persisted?

    render_validation_error(new_post)
  end

  def update
    return render_error('Post not found', 404) unless post.present?
    return render json: post, status: 200 if post.update(update_permitted_params)

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
    return @posts if @posts.present?

    # We try to get one more than the window size, to tell us if we need a next page link.
    @posts = current_user.posts.limit(API_PAGE_SIZE + 1)
    @posts.where!('created_at < ?', Time.zone.parse(Base64.urlsafe_decode64(params[:page]))) if params[:page].present?
    @posts.to_a
  end

  def pagination_needed?
    posts.size > API_PAGE_SIZE
  end

  def next_page_id
    @next_page_id ||= Base64.urlsafe_encode64(posts[API_PAGE_SIZE - 1].created_at.xmlschema(6))
  end

  def posts_links
    return nil unless pagination_needed?
    {
      next: v1_posts_url(page: next_page_id)
    }
  end

  def meta
    meta = { next_page: pagination_needed? }
    meta[:next_page_id] = next_page_id if pagination_needed?
    meta
  end
end
