class V1::LikeController < ApplicationController
  include ErrorResource

  def create
    return render_error('No post found for that ID', 404) if post.blank?

    current_user.like(post)

    head :no_content
  rescue ActiveRecord::RecordNotUnique
    render_error('You already liked this post', 422)
  end

  def destroy
    return render_error('No post found for that ID', 404) if post.blank?

    current_user.unlike(post)

    head :no_content
  end

  protected

  def post
    @post ||= Post.find_by(id: params[:post_id])
  end
end
