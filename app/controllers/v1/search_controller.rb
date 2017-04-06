class V1::SearchController < ApplicationController
  def users
    render json: User.search(params[:term]), each_serializer: UserListSerializer
  end

  def hash_tags
    render json: HashTag.search(params[:term].gsub('#', ''))
  end
end
