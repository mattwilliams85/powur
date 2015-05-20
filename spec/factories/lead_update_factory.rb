FactoryGirl.define do
  factory :lead_update do
    association :quote, factory: :complete_quote
    provider_uid { Faker::Code.isbn }
    status 'working_lead'
    data do
      { 'LeadStatus' => 'Called 3x', "Days Elapsed" => '3' }
    end
  end
end