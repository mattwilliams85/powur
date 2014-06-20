FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "email_#{n}@example.org" }
    first_name  'Will'
    last_name   'Farrel'
    phone       '858.555.1212'
    zip         '92127'
    password    'password'
    sequence(:url_slug) { |n| "#{first_name.downcase}_#{n}" }
    roles       [ 'admin' ]
  end
end