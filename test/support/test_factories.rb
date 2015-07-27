FactoryGirl.define do
  factory :rank do
    title { Faker::Name.title }
  end

  factory :lead, class: Quote do
    status :submitted
  end
end
