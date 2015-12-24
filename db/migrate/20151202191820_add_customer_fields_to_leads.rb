class AddCustomerFieldsToLeads < ActiveRecord::Migration
  def change
    add_column :leads, :first_name, :string
    add_column :leads, :last_name, :string
    add_column :leads, :email, :string
    add_column :leads, :phone, :string
    add_column :leads, :address, :string
    add_column :leads, :city, :string
    add_column :leads, :state, :string
    add_column :leads, :zip, :string
    add_column :leads, :notes, :string

    change_column :leads, :customer_id, :integer, null: true
  end
end
