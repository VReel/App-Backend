module FollowerFilters
  extend ActiveSupport::Concern

  def filter_to_follower_ids(records)
    return [] if current_user.blank?

    @follower_ids ||= Follow.where(following: current_user).where(follower_id: records.map(&:id)).map(&:follower_id)
  end

  def filter_to_following_ids(records)
    return [] if current_user.blank?

    @following_ids ||= Follow.where(follower: current_user).where(following_id: records.map(&:id)).map(&:following_id)
  end
end
