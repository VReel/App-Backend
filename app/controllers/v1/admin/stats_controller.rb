class V1::Admin::StatsController < V1::Admin::BaseController
  include ErrorResource

  def index
    render json: {
      data: {
        type: 'stats',
        meta: {
          date_from: date_from.try(:iso8601),
          date_to: date_to.try(:iso8601)
        },
        attributes: {
          users: users.count,
          posts: posts.count,
          top_users: top_users
        }
      }
    }
  end

  protected

  def date_from
    Time.zone.parse(params[:date_from]) if params[:date_from].present?
  end

  def date_to
    Time.zone.parse(params[:date_to]) if params[:date_to].present?
  end

  def users
    query = filters(User.all)
    query
  end

  def posts
    query = filters(Post.all)
    query
  end

  def top_users
    posts.group(:user_id).order('count_all DESC').count.first(20).map do |k, v|
      {
        user: ActiveModelSerializers::SerializableResource.new(User.find(k)),
        post_count: v
      }
    end
  end

  def filters(query)
    query.where!('created_at >= ?', date_from) if params[:date_from].present?
    query.where!('created_at <= ?', date_to) if params[:date_to].present?
    query
  end
end
