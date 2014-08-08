FactoryGirl.define do
  factory :order do
    quote
    user { quote.user }
    customer { quote.customer }
    product { quote.product }
    order_date { DateTime.current }
  end
end