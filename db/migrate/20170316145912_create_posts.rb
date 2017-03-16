class CreatePosts < ActiveRecord::Migration[5.0]
  def change
    create_table :posts, id: :uuid do |t|
      t.string :original_key, null: false
      t.string :thumbnail_key, null: false
      t.text :caption
      t.uuid :user_id, null: false
      t.timestamps
    end
    add_foreign_key :posts, :users
    add_index :posts, :user_id
  end
end
