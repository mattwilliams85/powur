class AddSmarteruEmployeeIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :smarteru_employee_id, :string, length: 50
  end
end
