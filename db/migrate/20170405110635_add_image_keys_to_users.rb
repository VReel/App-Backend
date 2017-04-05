class AddImageKeysToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :original_key, :string
    add_column :users, :thumbnail_key, :string
  end
end
