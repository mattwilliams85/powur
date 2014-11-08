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

    transient do
      group false
    end

    after(:create) do |field, evaluator|
      1.upto(3).each do |i|
        attrs = { value:       "#{field.name}-#{i}",
                  identifier:  i,
                  quote_field: field }
        attrs[:group] = 'GroupName' if evaluator.group
        create(:quote_field_lookup, attrs)
      end
    end
  end
end
