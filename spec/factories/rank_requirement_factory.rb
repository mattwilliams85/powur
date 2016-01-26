FactoryGirl.define do
  factory :rank_requirement do
    factory :purchase_requirement, class: PurchaseRequirement do
      rank_id 1
      time_span 2
    end
  end
end
