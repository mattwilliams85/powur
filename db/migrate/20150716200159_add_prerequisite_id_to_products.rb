class AddPrerequisiteIdToProducts < ActiveRecord::Migration
  def change
    add_column :products, :prerequisite_id, :integer
  end
end
