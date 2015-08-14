class AddLevelToBonusPaymentLeads < ActiveRecord::Migration
  def change
    add_column :bonus_payment_leads, :level, :integer
  end
end
