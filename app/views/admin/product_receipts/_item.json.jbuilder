klass :product_receipt

json.properties do
  json.call(product_receipt,
            :id, :product_id, :user_id,
            :amount, :transaction_id, :order_id, :auth_code,
            :created_at, :updated_at, :purchased_at)
  json.product Product.find(product_receipt.product_id)
  json.user User.find(product_receipt.user_id)
end
