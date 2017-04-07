class V1::FollowsController < ApplicationController
  include ErrorResource

  def create
    return render_error('No user found for that ID', 404) if followed_user.blank?

    current_user.follow(followed_user)

    head :no_content
  rescue ActiveRecord::RecordNotUnique
    render_error('That user is already followed', 422)
  end

  def destroy
    return render_error('No user found for that ID', 404) if followed_user.blank?

    current_user.unfollow(followed_user)

    head :no_content
  end

  protected

  def followed_user
    @followed_user ||= User.find_by(id: params[:user_id])
  end
end
