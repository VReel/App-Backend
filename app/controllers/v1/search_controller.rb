class V1::SearchController < ApplicationController
  def users
    render json: User.search(params[:term])
  end

  def hash_tags
    render json: HashTag.search(params[:term].delete('#'))
  end
end
