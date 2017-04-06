class CreateHashTagPosts < ActiveRecord::Migration[5.0]
  def change
    create_table :hash_tag_posts do |t|
      t.uuid :post_id, null: false
      t.uuid :hash_tag_id, null: false

      t.timestamps
    end

    add_foreign_key :hash_tag_posts, :posts
    add_index :hash_tag_posts, :post_id

    add_foreign_key :hash_tag_posts, :hash_tags
    add_index :hash_tag_posts, :hash_tag_id
  end
end
