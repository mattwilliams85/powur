class ChangeCallConsentedDefault < ActiveRecord::Migration
  REMOVED_MIGRATIONS = %w(20151222212620 20151222213336)

  def up
    ActiveRecord::SchemaMigration.where(version: REMOVED_MIGRATIONS).delete_all
  end

  def change
    change_column :leads, :call_consented, :boolean, default: false
  end
end
