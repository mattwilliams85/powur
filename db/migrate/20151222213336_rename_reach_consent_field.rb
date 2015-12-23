class RenameReachConsentField < ActiveRecord::Migration
  def change
    rename_column :leads, :reach_consent, :call_consented
  end
end
