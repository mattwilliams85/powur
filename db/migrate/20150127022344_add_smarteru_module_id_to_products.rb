class AddSmarteruModuleIdToProducts < ActiveRecord::Migration
  def change
    add_column :products, :smarteru_module_id, :string, limit: 50
  end
end
