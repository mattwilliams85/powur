class GeneratePayPeriods < ActiveRecord::Migration
  def up
    PayPeriod.generate_missing
  end
end
