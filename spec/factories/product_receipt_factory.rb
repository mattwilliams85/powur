FactoryGirl.define do
  factory :product_receipt do
    user_id 1
    product_id 2
    amount 1
    order_id 1
    transaction_id 100
    purchased_at Time.zone.now
  end
end
