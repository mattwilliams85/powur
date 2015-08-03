FactoryGirl.define do
  factory :lead do
    product
    customer
    user

    factory :complete_lead do
      association :product, factory: :solar_product
      data do
        { 'average_bill' => 230 }
      end
    end

    factory :submitted_lead do
      provider_uid { Faker::Code.isbn }
      submitted_at { DateTime.current }
      data_status :submitted
    end
  end
end
