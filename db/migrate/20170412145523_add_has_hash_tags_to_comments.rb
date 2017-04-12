class AddHasHashTagsToComments < ActiveRecord::Migration[5.0]
  def change
    add_column :comments, :has_hash_tags, :boolean, null: false, default: false
  end
end
