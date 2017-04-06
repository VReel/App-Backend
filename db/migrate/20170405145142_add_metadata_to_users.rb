class AddMetadataToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :follower_count, :integer, null: false, default: 0
    add_column :users, :following_count, :integer, null: false, default: 0
    add_column :users, :post_count, :integer, null: false, default: 0
  end
end
