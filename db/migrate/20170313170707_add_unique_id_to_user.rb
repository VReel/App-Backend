class AddUniqueIdToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :unique_id, :string
    add_index :users, :unique_id
  end
end
