class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string  :first_name, null: false
      t.string  :last_name, null: false
      t.string  :email
      t.string  :phone
      t.string  :address
      t.string  :city
      t.string  :state
      t.string  :zip
      t.timestamps null: false
    end

  end
end
