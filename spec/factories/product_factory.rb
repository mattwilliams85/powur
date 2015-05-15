FactoryGirl.define do
  factory :product do
    name { Faker::Commerce.product_name }
    bonus_volume 1000
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

    factory :certifiable_product do
      certifiable true
      image_original_path 'http://lorempixel.com/400/400/abstract'
    end

    factory(:solar_product) do
      name 'Solar Item'
      after(:create) do |product, _|
        create(:quote_field,
               product:   product,
               name:      'average_bill',
               required:  true,
               data_type: :number)
      end
    end
  end

  factory :product_enrollment do
    product_id 1
    user_id 1
  end
end
