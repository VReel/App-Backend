class V1::FlagsController < ApplicationController
  include ErrorResource
  before_action :check_post_is_found, only: [:create]

  def create
    new_flag = post.flags.create(permitted_params.merge(user: current_user))

    head :no_content if new_flag.persisted?
  end

  protected

  def post
    @post ||= Post.find_by(id: params[:post_id])
  end

  def check_post_is_found
    render_error('No post found for that ID', 404) if post.blank?
  end

  def permitted_params
    params.require(:flag).permit(:reason)
  end
end
