class AddBonusEndDates < ActiveRecord::Migration
  def change
    add_column :bonuses, :end_date, :date
  end
end
