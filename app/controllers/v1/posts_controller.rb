class V1::PostsController < ApplicationController
  def show
    return render json: post, status: 200 if post.present?

    render_error('Post not found', 404)
  end

  def create
    new_post = current_user.posts.create(create_permitted_params)

    return render json: new_post, status: 201 if new_post.persisted?

    render_validation_error
  end

  def update
    return render_error('Post not found', 404) unless post.present?
    return render json: post, status: 200 if post.update(update_permitted_params)

    render_validation_error
  end

  def destroy
    return render_error('Post not found', 404) unless post.present?

    if post.destroy
      head :no_content
    else
      render_validation_error
    end
  end

  protected

  def render_validation_error
    render json: post, serializer: ActiveModel::Serializer::ErrorSerializer, status: 422
  end

  def create_permitted_params
    params.require(:post).permit(:thumbnail_key,
                                 :original_key,
                                 :caption)
  end

  def update_permitted_params
    params.require(:post).permit(:caption)
  end

  def post
    @post ||= current_user.posts.find(params[:id])
  end
end
