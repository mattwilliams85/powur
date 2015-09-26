class AddCodeToProductInvites < ActiveRecord::Migration
  def change
    add_column :product_invites, :code, :string
    add_index :product_invites, [ :code ]
  end
end
