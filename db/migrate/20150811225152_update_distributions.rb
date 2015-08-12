class UpdateDistributions < ActiveRecord::Migration
  def change
    remove_column :distributions, :pay_period_id
    remove_column :distributions, :user_id
    remove_column :distributions, :amount

    add_column :distributions, :status, :integer, null: false, default: 1
    add_column :distributions, :title, :string

    add_column :pay_periods, :distribution_id, :integer
    add_column :bonuses, :distribution_id, :integer
    add_column :bonus_payments, :distribution_id, :integer
  end
end
