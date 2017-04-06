class CreateHashTags < ActiveRecord::Migration[5.0]
  def change
    create_table :hash_tags, id: :uuid do |t|
      t.string :tag, null: false

      t.timestamps
    end

    add_index :hash_tags, :tag, unique: true
    execute "CREATE INDEX hash_tags_tag_gin_trgm_idx ON hash_tags USING gist (tag gist_trgm_ops);"
  end
end
