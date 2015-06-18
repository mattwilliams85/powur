class AddCustomerNotes < ActiveRecord::Migration
  def change
    drop_table :customer_notes
    add_column :customers, :notes, :string
  end
end
