FactoryGirl.define do
  factory :user_group do
    id { Faker::Lorem.word }
    title { Faker::Name.title }
    description { Faker::Lorem.sentence }
  end

  factory :user_user_group do
    user
    user_group
  end

  factory :user_group_requirement do
    user_group
    product
    event_type :enrollment
  end
end
