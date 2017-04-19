class V1::CommentsController < ApplicationController
  include Pagination
  include ErrorResource
  before_action :check_post_is_found, only: [:index, :create]
  before_action :check_comment_is_found, only: [:update, :destroy]

  def index
    render json: comments.to_a.first(API_PAGE_SIZE), links: comment_links, meta: meta, include: :user
  end

  def create
    new_comment = post.comments.create(permitted_params.merge(user: current_user))

    return render json: new_comment, status: 201 if new_comment.persisted?

    render_validation_error(new_comment)
  end

  def update
    return render json: current_user_comment, status: 200 if current_user_comment.update(permitted_params)

    render_validation_error(current_user_comment)
  end

  def destroy
    head :no_content if current_user_comment.destroy
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

  def current_user_comment
    @current_user_comment ||= current_user.comments.find_by(id: params[:id])
  end

  def post
    @post ||= Post.find_by(id: params[:post_id])
  end

  def primary_records
    comments
  end

  def check_post_is_found
    render_error('No post found for that ID', 404) if post.blank?
  end

  def check_comment_is_found
    render_error('No comment found for that ID', 404) if current_user_comment.blank?
  end

  def permitted_params
    params.require(:comment).permit(:text)
  end

  def render_validation_error(comment)
    render json: comment, serializer: ActiveModel::Serializer::ErrorSerializer, status: 422
  end
end
