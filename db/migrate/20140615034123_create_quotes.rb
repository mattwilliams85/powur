class CreateQuotes < ActiveRecord::Migration
  def change
    create_table :quotes do |t|
      t.string  :url_slug, null: false
      t.hstore  :data, default: '', null: false

      t.belongs_to :customer, index: true, null: false
      t.belongs_to :product, index: true, null: false
      t.belongs_to :user, index: true, null: false

      t.foreign_key :customers, column: :customer_id, primary_key: :id
      t.foreign_key :products, column: :product_id, primary_key: :id
      t.foreign_key :users, column: :user_id, primary_key: :id

      t.timestamps null: false
    end
    add_index :quotes, [ :url_slug ], unique: true
  end
end
