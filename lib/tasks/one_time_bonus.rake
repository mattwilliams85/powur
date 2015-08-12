namespace :powur do
  task one_time_bonus: :environment do
    one_time_bonus = OneTimeBonus.first
    one_time_bonus.create_payments!
    one_time_bonus.distribute!
  end
end
