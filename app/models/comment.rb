class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post

  after_create { post.locked_increment(:comment_count) }
  after_destroy { post.locked_decrement(:comment_count) }
end
