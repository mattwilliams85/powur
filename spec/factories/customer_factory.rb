FactoryGirl.define do
  factory :customer do
    sequence(:email)  { |n| "customer.email_#{n}@example.org" }
    first_name        { Faker::Name.first_name }
    last_name         { Faker::Name.last_name }
    phone             { Faker::PhoneNumber.phone_number }
    address           { Faker::Address.street_address }
    zip               { Faker::Address.zip }
  end
end