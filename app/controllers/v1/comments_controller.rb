class V1::CommentsController < ApplicationController
  include Pagination
  include ErrorResource
  before_action :check_post_is_found

  def index
    render json: comments.first(API_PAGE_SIZE), links: comment_links, meta: meta, include: :user
  end

  def create
    new_comment = post.comments.create(permitted_params.merge(user: current_user))

    return render json: new_comment, status: 201 if new_comment.persisted?

    render_validation_error(new_post)
  end

  def update

  end

  protected

  def comments
    @comments ||= paginate(post.comments.includes(:user, :post), order: 'ASC')
  end

  def comment_links
    return nil unless pagination_needed?
    {
      next: v1_post_comments_url(params[:post_id], page: next_page_id)
    }
  end

  def post
    @post ||= Post.find_by(id: params[:post_id])
  end

  def records
    comments
  end

  def check_post_is_found
    render_error('No post found for that ID', 404) if post.blank?
  end

  def permitted_params
    params.require(:comment).permit(:text)
  end
end
