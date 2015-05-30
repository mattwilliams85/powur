FactoryGirl.define do
  factory :invite do
    sequence(:email) { |n| "testfoo+#{n}@test.com" }
    first_name 'Abe'
    last_name 'Lincoln'
    phone '3105551212'
    association :sponsor, factory: :user
  end
end
