FactoryGirl.define do
  factory :api_token do
    association :client, factory: :api_client
    user

    factory :expired_token do
      expires_at DateTime.current - 1.second
    end
  end
end
