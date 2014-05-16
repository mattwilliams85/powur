FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "email_#{n}@example.org" }
    first_name 'Will'
    last_name 'Farrel'
  end
end