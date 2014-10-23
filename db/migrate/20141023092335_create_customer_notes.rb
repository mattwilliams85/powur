class CreateCustomerNotes < ActiveRecord::Migration
  def change
    create_table :customer_notes do |t|
      t.references :customer, null: false
      t.integer :author_id, null: false
      t.string :note, limit: 1000
      t.timestamps null: false

      t.foreign_key :users, column: :author_id, primary_key: :id
    end
  end
end
