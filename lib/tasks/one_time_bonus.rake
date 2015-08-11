namespace :powur do
  task one_time_bonus: :environment do
    # TODO: think about how to deal with users that don't have an ewallet,
    # since they are the ones that should be creating it manually from their
    # profile page
    OneTimeBonus.first.create_payments!
    BonusPayment.distribute!
  end
end
