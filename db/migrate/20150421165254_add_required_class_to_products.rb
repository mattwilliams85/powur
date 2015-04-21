class AddRequiredClassToProducts < ActiveRecord::Migration
  def change
    add_column :products, :is_required_class, :boolean, default: false
  end
end
