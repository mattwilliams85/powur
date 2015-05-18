FactoryGirl.define do
  factory :zipcode do
    sequence(:zip) { |n| n.to_s.rjust(5, '0') }
  end

  factory :customer do
    sequence(:email)  { |n| "customer.email_#{n}@example.org" }
    first_name        { Faker::Name.first_name }
    last_name         { Faker::Name.last_name }
    phone             { Faker::PhoneNumber.phone_number }
    address           { Faker::Address.street_address }
    city              { Faker::Address.city }
    state             { Faker::Address.state_abbr }
    zip               { create(:zipcode).zip }

    factory :search_miss_customer do
      first_name 'xxx'
      last_name 'xxx'
    end
  end
end
