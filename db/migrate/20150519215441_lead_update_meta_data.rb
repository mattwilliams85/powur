class LeadUpdateMetaData < ActiveRecord::Migration
  def change
    add_column :lead_updates, :data, :hstore, default: ''
    add_column :lead_updates, :updated_at, :datetime, null: false
    add_column :quotes, :status, :integer, null: false, default: 0
  end
end
