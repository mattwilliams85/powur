FactoryGirl.define do
  factory :rank_achievement do
    pay_period { create(:monthly_pay_period) }
    user
    path 'default'
    achieved_at { DateTime.current }
  end
end
