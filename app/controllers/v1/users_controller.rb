class V1::UsersController < ApplicationController
  def index
    render json: current_user, status: 201
  end
end
