module Pagination
  extend ActiveSupport::Concern

  def paginate(query)
    query.limit!(API_PAGE_SIZE + 1)
    query.where!('created_at < ?', Time.zone.parse(Base64.urlsafe_decode64(params[:page]))) if params[:page].present?
  end

  def pagination_needed?
    records.size > API_PAGE_SIZE
  end

  def next_page_id
    @next_page_id ||= Base64.urlsafe_encode64(records[API_PAGE_SIZE - 1].created_at.xmlschema(6))
  end

  def meta
    meta = { next_page: pagination_needed? }
    meta[:next_page_id] = next_page_id if pagination_needed?
    meta
  end
end
