FactoryGirl.define do
  factory :customer do
    sequence(:email)  { |n| "customer.email_#{n}@example.org" }
    first_name        { Faker::Name.first_name }
    last_name         { Faker::Name.last_name }
    phone             '858.555.1212'
    address           '4873 Cherry LN'
    zip               '90210'
  end
end