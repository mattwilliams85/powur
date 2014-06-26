FactoryGirl.define do
  factory :product do
    name 'Solar Item'
    commissionable_volume 500.00
    quote_data %w(utility rate_schedule roof_material roof_age kwh)
  end
end
