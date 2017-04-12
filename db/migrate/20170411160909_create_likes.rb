class CreateLikes < ActiveRecord::Migration[5.0]
  def change
    create_table :likes do |t|
      t.uuid :post_id, null: false
      t.uuid :user_id, null: false

      t.timestamps
    end

    connection.execute('
      CREATE INDEX likes_created_at_index ON likes(created_at DESC NULLS LAST);
    ')
    add_index :likes, :post_id
    add_index :likes, :user_id
    add_index :likes, [:post_id, :user_id], unique: true
  end
end
