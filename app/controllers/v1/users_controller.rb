class V1::UsersController < ApplicationController
  def index
    render json: current_user, serializer: UserMeSerializer
  end
end
