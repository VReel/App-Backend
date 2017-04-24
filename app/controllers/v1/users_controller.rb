class V1::UsersController < ApplicationController
  include ErrorResource

  def index
    render json:
           current_user,
           serializer: UserFullSerializer
  end

  def show
    user = User.find_by(id: params[:id])

    if user
      render json: user,
             serializer: UserFullSerializer,
             follower_ids: follower_ids,
             following_ids: following_ids

    else
      render_error('No user found for that ID', 404)
    end
  end

  protected

  def follower_ids
    @follower_ids ||= Follow.where(following: current_user).where(follower_id: params[:id]).map(&:follower_id)
  end

  def following_ids
    @following_ids ||= Follow.where(follower: current_user).where(following_id: params[:id]).map(&:following_id)
  end
end
