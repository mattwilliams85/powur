FactoryGirl.define do
  factory :quote do
    # sequence(:url_slug) { |n| "url_slug_#{n}" }
    product
    customer
    user

    factory :complete_quote do
      data do
        { 'utility'      => 1,
          'average_bill' => 230,
          'square_feet'  => 2000 }
      end
    end
  end
end
