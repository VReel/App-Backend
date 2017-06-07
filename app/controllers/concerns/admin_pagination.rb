module AdminPagination
  extend ActiveSupport::Concern

  def paginate(query)
    query.limit!(API_PAGE_SIZE + 1)
    query.offset!(current_page * API_PAGE_SIZE)
    query
  end

  def next_page_id
    @next_page_id ||= current_page + 1
  end

  def current_page
    params[:page].present? ? Integer(params[:page]) : 0
  end

  def meta
    super.merge(total: query.dup.count)
  end
end
