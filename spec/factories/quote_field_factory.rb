FactoryGirl.define do
  factory :quote_field do
    product
    name { Faker::Commerce.product_name }
  end

  factory :quote_field_lookup do
    quote_field
    value { Faker::Commerce.product_name }
    sequence(:identifier)
  end
end