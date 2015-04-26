FactoryGirl.define do
  factory :bonus_payment do
    pay_period { create(:monthly_pay_period, at: DateTime.current - 1.month) }
    user
    pay_as_rank { SystemSettings.min_rank }
    association :bonus, factory: :seller_bonus
    amount { Faker::Commerce.price }
  end
end
