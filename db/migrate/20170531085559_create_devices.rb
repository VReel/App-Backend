class CreateDevices < ActiveRecord::Migration[5.0]
  def change
    create_table :devices do |t|
      t.uuid :user_id, null: false
      t.string :player_id
      t.timestamps
    end

    add_index :devices, :user_id
    add_foreign_key :devices, :users
    add_index :devices, :player_id, unique: true
  end
end
