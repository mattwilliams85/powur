class AddReachConcentToLeads < ActiveRecord::Migration
  def change
    add_column :leads, :call_consented, :boolean, default: true
  end
end
