class AddReachConcentToLeads < ActiveRecord::Migration
  def change
    add_column :leads, :reach_concent, :boolean, default: true
  end
end
