class Follow < ApplicationRecord
  belongs_to :follower, class_name: 'User'
  belongs_to :following, class_name: 'User'

  after_create do
    follower.locked_increment(:following_count)
    following.locked_increment(:follower_count)
  end

  after_destroy do
    follower.locked_decrement(:following_count)
    following.locked_decrement(:follower_count)
  end
end
