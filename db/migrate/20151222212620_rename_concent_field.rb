class RenameConcentField < ActiveRecord::Migration
  def change
    rename_column :leads, :reach_concent, :reach_consent
  end
end
