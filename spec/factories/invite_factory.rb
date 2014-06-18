FactoryGirl.define do
  factory :invite do
    email 'you@example.org'
    first_name 'Abe'
    last_name 'Lincoln'
    phone '3105551212'
    association :sponsor, factory: :user
  end
end
