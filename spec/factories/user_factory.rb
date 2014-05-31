FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "email_#{n}@example.org" }
    first_name  'Will'
    last_name   'Farrel'
    phone       '858.555.1212'
    zip         '92127'
    password    'password'
  end
end