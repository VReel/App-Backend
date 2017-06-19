class V1::LikesController < ApplicationController
  include Pagination
  include FollowerFilters
  prepend_before_action :allow_guest_access!, only: :index

  def index
    render json: likers.to_a.first(API_PAGE_SIZE),
           links: likers_links,
           meta: meta,
           follower_ids: filter_to_follower_ids(likers),
           following_ids: filter_to_following_ids(likers)
  end

  protected

  def likers
    @likers ||= likes.map(&:user)
  end

  def likes
    @likes ||= paginate(Like.where(post_id: params[:post_id]).order('created_at ASC').includes(:user), order: 'ASC')
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

  def primary_records
    likes
  end
end
