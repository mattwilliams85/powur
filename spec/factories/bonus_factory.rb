FactoryGirl.define do
  factory :bonus do
    name Faker::Commerce.product_name

    factory :direct_sales_bonus, class: DirectSalesBonus
    factory :enroller_sales_bonus, class: EnrollerSalesBonus do
      max_user_rank 1
      min_upline_rank 2
    end

    factory :unilevel_sales_bonus, class: UnilevelSalesBonus
    factory :promote_out_bonus, class: PromoteOutBonus
    factory :differential_bonus, class: DifferentialBonus
  end

  factory :bonus_requirement, class: BonusSalesRequirement do
    association :bonus, factory: :direct_sales_bonus
    product
  end
end
