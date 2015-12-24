class MoveFieldsFromCustomersToLeads < ActiveRecord::Migration
  def change
    add_column :leads, :code, :string
    add_column :leads, :invite_status, :integer, default: 0
    add_column :leads, :last_viewed_at, :datetime
    add_column :leads, :mandrill_id, :string
  end
end
