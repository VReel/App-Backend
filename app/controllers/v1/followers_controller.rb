class V1::FollowersController < ApplicationController
  include Pagination

  def followers
    render json: followers_of_user.to_a.first(API_PAGE_SIZE), links: followers_links, meta: meta
  end

  def following
    render json: users_user_follows.to_a.first(API_PAGE_SIZE), links: following_links, meta: meta
  end

  protected

  def user
    current_user
  end

  def users_user_follows
    @users_user_follows ||= following_relationships.map(&:following)
  end

  def followers_of_user
    @followers_of_user ||= follower_relationships.map(&:follower)
  end

  def following_relationships
    @following_relationships ||= paginate(user.following_relationships.includes(:following))
  end

  def follower_relationships
    @follower_relationships ||= paginate(user.follower_relationships.includes(:follower))
  end

  # Needed for pagination.
  # We need to specify the record we are selecting from (followers/following), not the one we display (users)
  # so pagination is on the correct created_at timestamp.
  def primary_records
    return following_relationships if request.path[/following/]

    follower_relationships
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
