FactoryGirl.define do
  factory :quote do
    product
    customer
    user

    factory :complete_quote do
      association :product, factory: :solar_product
      data do
        { 'average_bill' => 230 }
      end
    end

    factory :submitted_quote do
      provider_uid { Faker::Code.isbn }
      submitted_at { DateTime.current }
      status :submitted
    end
  end
end
