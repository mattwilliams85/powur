FactoryGirl.define do
  factory :lead_udpate do
    quote
    provider_uid { Faker::Code.isbn }
    status 'existing_active'
    opportunity_status 'closed_won'
  end
end