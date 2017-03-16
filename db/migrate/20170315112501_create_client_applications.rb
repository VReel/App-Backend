class CreateClientApplications < ActiveRecord::Migration[5.0]
  def change
    create_table :client_applications do |t|
      t.string :name
      t.string :application_id
      t.datetime :deleted_at
      t.timestamps
    end

    add_index :client_applications, :deleted_at
    add_index :client_applications, :application_id, unique: true
  end
end
