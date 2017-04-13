class LikesCreatedAtAscIndex < ActiveRecord::Migration[5.0]
  def change
    connection.execute('
      CREATE INDEX likes_created_at_asc_index ON likes(created_at ASC NULLS LAST);
    ')
  end
end
