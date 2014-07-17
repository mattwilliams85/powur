FactoryGirl.define do
  factory :bonus do
    name Faker::Commerce.product_name
  end

  factory :bonus_requirement, class: BonusSalesRequirement do
    bonus
    product
  end
end
