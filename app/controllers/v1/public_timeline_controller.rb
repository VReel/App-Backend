class V1::PublicTimelineController < V1::PostsController
  protected

  def posts
    @posts ||= Post.all.order('created_at DESC')
  end

  def posts_links
    return nil unless pagination_needed?
    {
      next: v1_public_timeline_url(page: next_page_id)
    }
  end
end
