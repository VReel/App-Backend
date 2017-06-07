class V1::Admin::UsersController < V1::Admin::BaseController
  include AdminPagination

  def index
    render json: users.to_a.first(API_PAGE_SIZE),
           links: users_links,
           meta: meta,
           each_serializer: UserAdminSerializer
  end

  protected

  def primary_records
    users
  end

  def users
    return @users unless @users.nil?
    @users = query
    paginate(@users)
    @users
  end

  def users_links
    return nil unless pagination_needed?
    {
      next: v1_admin_users_url(page: next_page_id)
    }
  end

  def query
    q = User.all

    q.order(order_clause)
  end

  def order_clause
    case params[:sort]
    when 'created_at_asc'
      'created_at ASC'
    else
      # The default option
      'created_at DESC'
    end
  end
end
