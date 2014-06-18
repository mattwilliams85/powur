FactoryGirl.define do
  factory :customer do
    sequence(:email)      { |n| "customer.email_#{n}@example.org" }
    sequence(:first_name) { |n| "Abe_#{n}" }
    sequence(:last_name)  { |n| "Lincoln#{n}" }
    phone                 '858.555.1212'
    address               '4873 Cherry LN'
    zip                   '90210'
  end
end