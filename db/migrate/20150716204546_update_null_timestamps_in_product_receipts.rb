class UpdateNullTimestampsInProductReceipts < ActiveRecord::Migration
  def up
    y2k = Time.zone.parse('Jan 1 2000 12:00:00')
    ProductReceipt.where('created_at is null').each { |x| x.update_column(:created_at, y2k) }
    ProductReceipt.where('updated_at is null').each { |x| x.update_column(:updated_at, y2k) }
  end

  def down

  end
end
