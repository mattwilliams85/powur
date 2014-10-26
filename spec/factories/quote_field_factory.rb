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

  factory :lookup_field, class: QuoteField do
    data_type :lookup
    after(:create) do |field, _evaluator|
      1.upto(3).each do |i|
        create(:quote_field_lookup, value: "#{field.name}-#{i}", identifier: i)
      end
    end
  end

end