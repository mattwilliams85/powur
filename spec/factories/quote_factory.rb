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
  end
end
