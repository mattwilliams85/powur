FactoryGirl.define do
  factory :bonus do
    name Faker::Commerce.product_name

    factory :direct_sales_bonus, class: DirectSalesBonus do
      schedule :weekly
    end

    factory :enroller_sales_bonus, class: EnrollerSalesBonus do
      schedule :weekly
      association :max_user_rank, factory: :rank
      association :min_upline_rank, factory: :rank
      compress true
    end

    factory :unilevel_sales_bonus, class: UnilevelSalesBonus do
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
    association :bonus, factory: :unilevel_sales_bonus
    sequence(:level, 0)
    amounts [ 0.1, 0.2, 0.3, 0.4, 0.5 ]
  end
end
