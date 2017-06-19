class V1::UsersController < ApplicationController
  include ErrorResource
  include FollowerFilters
  prepend_before_action :allow_guest_access!, only: :show

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
             follower_ids: filter_to_follower_ids([user]),
             following_ids: filter_to_following_ids([user])

    else
      render_error('No user found for that ID', 404)
    end
  end
end
