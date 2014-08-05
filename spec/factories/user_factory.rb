FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "email_#{n}@example.org" }
    first_name  Faker::Name.first_name
    last_name   Faker::Name.last_name
    contact({ 'phone' => '858.555.1212', 'zip' => '92127' })
    password    'password'
    sequence(:url_slug) { |n| "#{first_name.downcase}_#{n}" }
    roles       [ 'admin' ]
  end
end