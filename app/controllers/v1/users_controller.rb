class V1::UsersController < ApplicationController
  include ErrorResource

  def index
    render json: current_user
  end

  def show
    user = User.find_by(id: params[:id])

    if user
      render json: user
    else
      render_error('No user found for that ID', 404)
    end
  end
end
