class AugustBonus < ActiveRecord::Migration
  def up
    add_column :bonuses, :pay_period_id, :string
    add_foreign_key :bonuses, :pay_periods
    change_column :bonus_payments, :pay_period_id, :string, null: true
    if (bonus = OneTimeBonus.first)
      BonusPayment.where(bonus_id: bonus.id).update_all(pay_period_id: nil)
    end
    WeeklyPayPeriod.find_or_create_by_id('2015W36')
    OneTimeBonus.create!(
      id:       9,
      name:     'August Contest',
      amount:   '25.0',
      criteria: 'august_contest',
      schedule: 3)
    Bonus.where(id: 9).update_all(pay_period_id: '2015W36')
    Bonus.reset_auto_id
  end

  def down
    BonusPayment.where(bonus_id: 9).delete_all
    bonus = Bonus.find_by(id: 9)
    bonus && bonus.destroy
    remove_column :bonuses, :pay_period_id
    change_column :bonus_payments, :pay_period_id, :string, null: false
  end
end
