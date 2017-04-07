class V1::FollowersController < ApplicationController
  include Pagination

  def followers
    render json: following_users.first(API_PAGE_SIZE), links: followers_links, meta: meta
  end

  def following
    render json: followed_users.first(API_PAGE_SIZE), links: following_links, meta: meta
  end

  protected

  # rubocop:disable all
  def followed_users
    return @followed_users unless @followed_users.nil?

    following_relationships = current_user.following_relationships.includes(:following)
    paginate(following_relationships)

    @followed_users = following_relationships.map(&:following)
  end

  def following_users
    return @following_users unless @following_users.nil?

    follower_relationships = current_user.follower_relationships.includes(:follower)
    paginate(follower_relationships)

    @following_users = follower_relationships.map(&:follower)
  end
   # rubocop:enable all

  def records
    return followed_users if request.path[/following/]

    following_users
  end

  def followers_links
    return nil unless pagination_needed?
    {
      next: v1_followers_url(page: next_page_id)
    }
  end

  def following_links
    return nil unless pagination_needed?
    {
      next: v1_following_url(page: next_page_id)
    }
  end
end
