FactoryGirl.define do
  factory :order_total do
    pay_period { MonthlyPayPeriod.find_or_create_by_date(DateTime.current) }
    user
    product
    personal_total { Random.rand(100) }
    group_total { personal_total + Random.rand(100) }
  end
end