class V1::LikesController < ApplicationController
  include Pagination

  def index
    render json: likers.first(API_PAGE_SIZE), links: likers_links, meta: meta
  end

  protected

  def likers
    return @likers unless @likers.nil?

    likes = Like.where(post_id: params[:post_id]).order('created_at DESC').includes(:user)
    paginate(likes)

    @likers = likes.map(&:user)
  end

  def likers_links
    return nil unless pagination_needed?
    {
      next: v1_post_likes_url(params[:post_id], page: next_page_id)
    }
  end

  def post
    @post ||= Posts.find_by(id: params[:post_id])
  end

  def records
    likers
  end
end
