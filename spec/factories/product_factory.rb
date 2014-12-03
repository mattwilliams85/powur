FactoryGirl.define do
  factory :product do
    name { Faker::Commerce.product_name }
    bonus_volume 500
    commission_percentage 100

    factory :product_with_quote_fields do
      transient do
        field_count 2
      end

      after(:create) do |product, evaluator|
        create_list(:quote_field, evaluator.field_count, product: product)
      end
    end

    factory :default_product do
      after(:create) do |product, _|
        SystemSettings.default_product_id = product.id
      end
    end

    factory :sunrun_product do
      name 'SunRun Solar Item'

      after(:create) do |product, _|
        create(:quote_field,
               product:   product,
               name:      'average_bill',
               required:  true,
               data_type: :number)
        { square_feet:            :number,
          credit_score_qualified: :boolean,
          roof_type:              :lookup,
          roof_age:               :lookup }.each do |name, data_type|
          if data_type == :lookup
            create(:lookup_field, name: name.to_s, product: product)
          else
            create(:quote_field,
                   product:   product,
                   name:      name,
                   data_type: data_type)
          end
        end
        create(:lookup_field, name: 'utility', product: product, group: true)

        SystemSettings.default_product_id = product.id
      end
    end
  end
end
