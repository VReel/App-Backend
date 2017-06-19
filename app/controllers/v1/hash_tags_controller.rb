class V1::HashTagsController < ApplicationController
  include ErrorResource
  prepend_before_action :allow_guest_access!

  def show
    return render_error('Hash tag not found', 404) if hash_tag.blank?
    # We inherit pagination and meta links from posts controller.
    render json: hash_tag
  end

  protected

  def hash_tag
    # if the hash_tag does not start with a #, assume it is a uuid.
    @hash_tag ||= if params[:id].first == '#'
                    HashTag.find_with_tag(params[:id])
                  else
                    HashTag.find_by(id: params[:id])
                  end
  end
end
