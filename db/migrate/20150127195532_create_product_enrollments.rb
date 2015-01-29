class CreateProductEnrollments < ActiveRecord::Migration
  def change
    create_table :product_enrollments do |t|
      t.integer :product_id
      t.integer :user_id
      t.string :state
      t.timestamps
    end

    add_index :product_enrollments, [:user_id, :product_id]
  end
end
