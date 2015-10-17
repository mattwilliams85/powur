class AddFieldsToCustomers < ActiveRecord::Migration
  def change
    add_column :customers, :user_id, :integer
    add_column :customers, :code, :string
    add_column :customers, :status, :integer, null: false, default: 0

    add_index :customers, [ :code ]
  end
end
