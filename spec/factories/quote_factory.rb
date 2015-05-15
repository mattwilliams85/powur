FactoryGirl.define do
  factory :quote do
    # sequence(:url_slug) { |n| "url_slug_#{n}" }
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
