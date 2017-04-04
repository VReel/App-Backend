class AddUserSearchIndexes < ActiveRecord::Migration[5.0]
  def change
    execute "create extension pg_trgm;"
    execute "CREATE INDEX users_handle_gin_trgm_idx ON users USING gist (handle gist_trgm_ops);"
    execute "CREATE INDEX users_name_gin_trgm_idx ON users USING gist (name gist_trgm_ops);"
  end
end
