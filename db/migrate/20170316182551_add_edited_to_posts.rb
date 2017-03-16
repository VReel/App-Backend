class AddEditedToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :edited, :boolean, default: false
  end
end
