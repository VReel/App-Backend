class AddForeignKeys < ActiveRecord::Migration[5.0]
  def change
    add_foreign_key :comments, :posts
    add_foreign_key :comments, :users
    add_foreign_key :likes, :posts
    add_foreign_key :likes, :users
  end
end
