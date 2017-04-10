class V1::FollowersController < ApplicationController
  include Pagination

  def followers
    render json: followers_of_current_user.first(API_PAGE_SIZE), links: followers_links, meta: meta
  end

  def following
    render json: users_current_user_follows.first(API_PAGE_SIZE), links: following_links, meta: meta
  end

  protected

  def users_current_user_follows
    return @users_current_user_follows unless @users_current_user_follows.nil?

    following_relationships = current_user.following_relationships.includes(:following)
    paginate(following_relationships)

    @users_current_user_follows = following_relationships.map(&:following)
  end

  def followers_of_current_user
    return @followers_of_current_user unless @followers_of_current_user.nil?

    follower_relationships = current_user.follower_relationships.includes(:follower)
    paginate(follower_relationships)

    @followers_of_current_user = follower_relationships.map(&:follower)
  end

  # Needed for pagination
  def records
    return users_current_user_follows if request.path[/following/]

    followers_of_current_user
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
