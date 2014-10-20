FactoryGirl.define do
  factory :order_total do
    pay_period { MonthlyPayPeriod.find_or_create_by_date(1.month.ago) }
    user
    product
    personal { Random.rand(100) }
    group { personal + Random.rand(100) }
    personal_lifetime { personal + Random.rand(100) }
    group_lifetime { personal_lifetime + Random.rand(100) }
  end
end
