namespace :powur do
  namespace :bonus do
    task one_time: :environment do
      one_time_bonus = OneTimeBonus.first
      one_time_bonus.create_payments!
      one_time_bonus.distribute!
    end

    task update_pay_period_total: :environment do
      PayPeriod.calculated.preload(:bonus_payments).find_each do |pp|
        pp.update_column(:total_bonus, pp.bonus_total)
      end
    end
  end
end
