FactoryGirl.define do
  factory :quote do
    # sequence(:url_slug) { |n| "url_slug_#{n}" }

    product
    customer
    user
  end
end
