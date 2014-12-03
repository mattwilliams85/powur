FactoryGirl.define do

  factory :bonus_plan do
    name Faker::Commerce.product_name
  end

  factory :bonus do
    bonus_plan
    name { Faker::Commerce.product_name }
    use_rank_at :pay_period_end

    factory :direct_sales_bonus, class: DirectSalesBonus do
      schedule :weekly
      use_rank_at :sale
    end

    factory :enroller_bonus, class: EnrollerBonus do
      schedule :monthly
      # association :max_user_rank, factory: :rank
      # association :min_upline_rank, factory: :rank
      compress true
    end

    factory :unilevel_bonus, class: UnilevelBonus do
      schedule :monthly
      compress true
    end

    factory :promote_out_bonus, class: PromoteOutBonus do
      schedule :monthly
      association :achieved_rank, factory: :rank
      association :min_upline_rank, factory: :rank
      compress true
    end

    factory :differential_bonus, class: DifferentialBonus do
      schedule :monthly

      association :max_user_rank, factory: :rank
      association :min_upline_rank, factory: :rank
    end
  end

  factory :bonus_requirement, class: BonusSalesRequirement do
    association :bonus, factory: :direct_sales_bonus
    product
    source true
  end

  factory :bonus_level do
    association :bonus, factory: :direct_sales_bonus
    level 0
    amounts [ 0.1, 0.2, 0.3, 0.4, 0.5 ]
  end
end
