class ChangeCallConsentedToNotNull < ActiveRecord::Migration
  def change
    change_column :leads, :call_consented, :boolean, default: false, null: false
  end
end
