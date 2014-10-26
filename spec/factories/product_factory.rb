FactoryGirl.define do
  factory :product do
    name { Faker::Commerce.product_name }
    bonus_volume 500
    commission_percentage 100
    quote_data %w(utility average_bill rate_schedule square_feet estimated_credit)
  end

end
