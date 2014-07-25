FactoryGirl.define do
  factory :bonus do
    name Faker::Commerce.product_name

    factory :direct_sales_bonus, class: DirectSalesBonus do
      schedule :monthly
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
    end
  end

  factory :bonus_requirement, class: BonusSalesRequirement do
    association :bonus, factory: :direct_sales_bonus
    product
  end
end
