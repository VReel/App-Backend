class V1::Admin::PostsController < V1::PublicTimelineController
  before_action :authenticate_chief!
end
