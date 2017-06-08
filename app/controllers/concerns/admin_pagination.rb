module AdminPagination
  extend ActiveSupport::Concern

  def paginate(query)
    query.limit!(API_PAGE_SIZE + 1)
    query.offset!(current_page * API_PAGE_SIZE)
    query
  end

  # We need to specify the record we are selecting from for primary record, not necessarily the one we display
  # so pagination is on the correct created_at timestamp.
  def pagination_needed?
    # Using #to_a stops active record trying to be clever
    # by converting queries to select count(*)s which then need to be repeated.
    @pagination_needed ||= primary_records.to_a.size > API_PAGE_SIZE
  end

  def next_page_id
    @next_page_id ||= current_page + 1
  end

  def current_page
    params[:page].present? ? Integer(params[:page]) : 0
  end

  def meta
    meta = { next_page: pagination_needed?, total: query.dup.count }
    meta[:next_page_id] = next_page_id if pagination_needed?
    meta
  end
end
