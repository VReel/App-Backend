class DropCommentForeignKeys < ActiveRecord::Migration[5.0]
  def change
    remove_foreign_key :comments, :posts
    remove_foreign_key :comments, :users
  end
end
