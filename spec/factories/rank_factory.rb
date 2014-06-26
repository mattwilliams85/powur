FactoryGirl.define do
  factory :rank do
    sequence(:id)
    title { Faker::Name.title }
  end
end