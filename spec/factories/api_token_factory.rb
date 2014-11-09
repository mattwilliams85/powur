FactoryGirl.define do
  factory :api_token do
    association :client, factory: :api_client
    user
  end
end