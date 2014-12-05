class AddMetaDataToBonuses < ActiveRecord::Migration
  def change
    add_column :bonuses, :meta_data, :hstore
  end
end
