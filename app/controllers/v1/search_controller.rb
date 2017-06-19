class V1::SearchController < ApplicationController
  prepend_before_action :allow_guest_access!

  def users
    render json: User.search(params[:term])
  end

  def hash_tags
    render json: HashTag.search(params[:term].delete('#'))
  end
end
