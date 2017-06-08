class V1::Admin::UsersController < V1::Admin::BaseController
  include AdminPagination

  def index
    render json: users.to_a.first(API_PAGE_SIZE),
           links: users_links,
           meta: meta,
           each_serializer: UserAdminSerializer
  end

  def show
    render json:
           User.find(params[:id]),
           serializer: UserAdminSerializer
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

  # rubocop:disable all
  def query
    q = User.all
    q.where!('users.created_at >= ?', Time.zone.parse(params[:date_from]).beginning_of_day) if params[:date_from].present?
    q.where!('users.created_at <= ?', Time.zone.parse(params[:date_to]).end_of_day) if params[:date_to].present?
    q.where!('users.post_count >= ?', params[:min_posts].to_i) if params[:min_posts].present?
    q.where!('users.post_count <= ?', params[:max_posts].to_i) if params[:max_posts].present?
    q.where!('users.follower_count >= ?', params[:min_followers].to_i) if params[:min_followers].present?
    q.where!('users.follower_count <= ?', params[:max_followers].to_i) if params[:max_followers].present?
    q.where!('users.following_count >= ?', params[:min_following].to_i) if params[:min_following].present?
    q.where!('users.following_count <= ?', params[:max_following].to_i) if params[:max_following].present?
    if params[:follows_user].present?
      q.where!('users.id IN (SELECT follower_id FROM follows WHERE following_id IN (SELECT id FROM users WHERE handle ilike(?)))', params[:follows_user])
    end
    if params[:following_user].present?
      q.where!('users.id IN (SELECT following_id FROM follows WHERE follower_id IN (SELECT id FROM users WHERE handle ilike(?)))', params[:following_user])
    end
    q.where!('users.handle like (?)', "#{params[:handle]}%") if params[:handle].present?
    if params[:confirmed].present?
      if params[:confirmed] == 'true'
        q.where!('users.confirmed_at IS NOT NULL')
      else
        q.where!('users.confirmed_at IS NULL')
      end
    end
    q.order(order_clause)
  end
  # rubocop:enable all

  def order_clause
    case params[:sort]
    when 'created_at_asc'
      'created_at ASC'
    when 'confirmed_at_desc'
      'confirmed_at DESC'
    when 'confirmed_at_asc'
      'confirmed_at ASC'
    when 'posts_desc'
      'post_count DESC'
    when 'posts_asc'
      'post_count ASC'
    when 'followers_desc'
      'follower_count DESC'
    when 'followers_asc'
      'follower_count ASC'
    when 'following_desc'
      'following_count DESC'
    when 'following_asc'
      'following_count ASC'
    else
      # The default option
      'created_at DESC'
    end
  end
end
