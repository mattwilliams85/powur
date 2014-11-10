FactoryGirl.define do
  factory :api_client do
    id { "#{Faker::Internet.domain_word}.#{Faker::Internet.domain_name}" }
    secret { Faker::Internet.password }
  end
end
