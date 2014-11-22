FactoryGirl.define do
  factory :rank_achievement do
    pay_period { create(:monthly_pay_period) }
    user
    rank_path
    achieved_at { DateTime.current }
  end
end
