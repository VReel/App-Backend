class AddCommentCountToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :comment_count, :integer, null: false, default: 0
  end
end
