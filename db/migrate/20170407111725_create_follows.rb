class CreateFollows < ActiveRecord::Migration[5.0]
  def change
    create_table :follows do |t|
      t.uuid :following_id, null: false
      t.uuid :follower_id, null: false

      t.timestamps
    end

    connection.execute('
      CREATE INDEX follows_created_at_index ON follows(created_at DESC NULLS LAST);
    ')
    add_index :follows, :following_id
    add_index :follows, :follower_id
    add_index :follows, [:following_id, :follower_id], unique: true
  end
end
