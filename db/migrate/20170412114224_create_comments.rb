class CreateComments < ActiveRecord::Migration[5.0]
  def change
    create_table :comments, id: :uuid  do |t|
      t.uuid :post_id, null: false
      t.uuid :user_id, null: false
      t.text :text

      t.timestamps
    end

    connection.execute('
      CREATE INDEX comments_created_at_index ON likes(created_at ASC NULLS LAST);
    ')
    add_index :comments, :post_id
    add_index :comments, :user_id
    add_index :comments, [:post_id, :user_id]
    add_foreign_key :comments, :posts
    add_foreign_key :comments, :users
  end
end
