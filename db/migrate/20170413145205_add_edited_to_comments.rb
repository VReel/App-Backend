class AddEditedToComments < ActiveRecord::Migration[5.0]
  def change
    add_column :comments, :edited, :boolean, default: false
  end
end
