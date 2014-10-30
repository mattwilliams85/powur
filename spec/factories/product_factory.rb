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
        fields = {
          utility:          :lookup,
          average_bill:     :number,
          rate_schedule:    :lookup,
          square_feet:      :number,
          credit_approved:  :boolean,
          roof_type:        :lookup,
          roof_age:         :lookup }
        fields.each do |name, data_type|
          if data_type == :lookup
            create(:lookup_field, name: name, product: product)
          else
            create(:quote_field,
                   product:   product,
                   name:      name,
                   data_type: data_type)
          end
        end
        SystemSettings.default_product_id = product.id
      end
    end
  end
end
