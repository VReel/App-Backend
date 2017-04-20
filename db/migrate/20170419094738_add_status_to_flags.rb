class AddStatusToFlags < ActiveRecord::Migration[5.0]
  def change
    add_column :flags, :status, :integer, null: false, default: 0
    add_index :flags, :status
  end
end
