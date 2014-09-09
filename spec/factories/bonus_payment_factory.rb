FactoryGirl.define do
  factory :bonus_payment do
    pay_period { MonthlyPayPeriod.find_or_create_by_date(DateTime.current - 1.month) }
    user
    association :bonus, factory: :direct_sales_bonus
    amount { Faker::Commerce.price }
  end
end
