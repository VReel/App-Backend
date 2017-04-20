class CreateFlags < ActiveRecord::Migration[5.0]
  def change
    create_table :flags do |t|
      t.uuid :post_id, null: false
      t.uuid :user_id, null: false
      t.text :reason

      t.timestamps
    end

    add_index :flags, :post_id
    add_index :flags, :user_id
    add_foreign_key :flags, :posts
    add_foreign_key :flags, :users
  end
end
