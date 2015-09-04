class AugustBonus < ActiveRecord::Migration
  def up
    OneTimeBonus.create!(
      id:       9,
      name:     'August Contest',
      amount:   '25.0',
      criteria: 'august_contest',
      schedule: 3)
    Bonus.reset_auto_id
  end

  def down
    Bonus.find(9).destroy
  end
end
