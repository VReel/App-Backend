class CreatePosts < ActiveRecord::Migration[5.0]
  def change
    create_table :posts do |t|
      t.string :url, null: false
      t.string :thumbnail_url: false
      t.string :caption
      t.references :user, index: true
      t.timestamps
    end
  end
end
