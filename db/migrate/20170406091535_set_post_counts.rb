class SetPostCounts < ActiveRecord::Migration[5.0]
  def change
    User.all.each do |user|
      user.update_columns(post_count: user.posts.with_deleted.count)
    end
  end
end
