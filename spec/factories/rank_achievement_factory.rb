FactoryGirl.define do
  factory :rank_achievement do
    pay_period { MonthlyPayPeriod.find_or_create_by_date(DateTime.current - 1.month) }
    user
    path 'default'
    achieved_at { DateTime.current }
  end
end
