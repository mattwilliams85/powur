class RenameDistributionTitleToBatchId < ActiveRecord::Migration
  def change
    rename_column :distributions, :title, :batch_id
  end
end
