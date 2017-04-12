class Like < ApplicationRecord
  belongs_to :user
  belongs_to :post

  after_create { post.locked_increment(:like_count) }
  after_destroy { post.locked_decrement(:like_count) }
end
