FactoryGirl.define do
  factory :product do
    name { Faker::Commerce.product_name }
    bonus_volume 500
    commission_percentage 100
    quote_data %w(utility rate_schedule roof_material roof_age kwh)
  end
end
