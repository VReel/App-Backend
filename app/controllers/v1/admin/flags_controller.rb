class V1::Admin::FlagsController < V1::Admin::BaseController
  include ErrorResource
  include Pagination
  before_action :check_post_is_found, only: :index

  def index
    render json: flags.to_a.first(API_PAGE_SIZE),
           links: flag_links,
           meta: meta,
           include: [:user, post: :user]
  end

  protected

  def flags
    @flags ||= paginate(post.flags.where(status: :awaiting).order('created_at DESC'))
  end

  def post
    @post ||= Post.find_by(id: params[:flagged_post_id])
  end

  def flag_links
    return nil unless pagination_needed?
    {
      next: v1_admin_flags_url(params[:flagged_post_id], page: next_page_id)
    }
  end

  def primary_records
    flags
  end

  def check_post_is_found
    render_error('No post found for that ID', 404) if post.blank?
  end
end
