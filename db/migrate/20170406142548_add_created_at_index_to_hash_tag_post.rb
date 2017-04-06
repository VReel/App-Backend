class AddCreatedAtIndexToHashTagPost < ActiveRecord::Migration[5.0]
  def change
    connection.execute('
      CREATE INDEX hash_tag_posts_created_at_index ON hash_tag_posts(created_at DESC NULLS LAST);
    ')
  end
end
