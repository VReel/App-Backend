class AddModeratedToPost < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :moderated, :boolean, default: false
  end
end
