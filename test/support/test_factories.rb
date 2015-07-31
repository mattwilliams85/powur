FactoryGirl.define do
  factory :rank do
    title { Faker::Name.title }
  end

  factory :lead, class: Lead do
    data_status :submitted
  end
end
