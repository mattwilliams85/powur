FactoryGirl.define do
  factory :rank_path do
    name { Faker::Name.title }
    sequence(:precedence, 2)

    factory :default_rank_path do
      precedence 1
    end
  end
end
