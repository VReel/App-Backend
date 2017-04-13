class V1::OtherUserFollowersController < V1::FollowersController
  protected

  def user
    @user ||= User.find_by(id: params[:user_id])
  end

  def followers_links
    return nil unless pagination_needed?
    {
      next: v1_user_followers_url(page: next_page_id)
    }
  end

  def following_links
    return nil unless pagination_needed?
    {
      next: v1_user_following_url(page: next_page_id)
    }
  end
end
