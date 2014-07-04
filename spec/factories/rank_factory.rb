FactoryGirl.define do
  factory :rank do
    title Faker::Name.title

    factory :qualified_rank  do
      after(:create) do |rank, evaluator|
        create(:certification_qualification, rank: rank)
        create(:sales_qualification, rank: rank)
        create(:group_sales_qualification, rank: rank)
      end
    end
  end
end