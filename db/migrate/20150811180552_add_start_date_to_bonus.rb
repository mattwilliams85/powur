class AddStartDateToBonus < ActiveRecord::Migration
  def change
    add_column :bonuses, :start_date, :datetime
    add_column :bonus_payment_leads, :status, :integer, null: false
  end
end
