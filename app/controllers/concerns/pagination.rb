module Pagination
  extend ActiveSupport::Concern

  def paginate(query, order: 'DESC')
    query.limit!(API_PAGE_SIZE + 1)
    filter = "created_at #{order == 'DESC' ? '<' : '>'} ?"
    query.where!(filter, Time.zone.parse(Base64.urlsafe_decode64(params[:page]))) if params[:page].present?
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
    @next_page_id ||= Base64.urlsafe_encode64(primary_records[API_PAGE_SIZE - 1].created_at.xmlschema(6))
  end

  def meta
    meta = { next_page: pagination_needed? }
    meta[:next_page_id] = next_page_id if pagination_needed?
    meta
  end
end
