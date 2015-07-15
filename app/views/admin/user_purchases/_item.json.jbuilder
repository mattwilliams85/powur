klass :product_receipt

json.properties do
  json.call(product_receipt,
            :id,
            :product_id,
            :user_id,
            :amount,
            :transaction_id,
            :order_id,
            :auth_code,
            :created_at,
            :updated_at)
  json.product_name Product.find(product_receipt.product_id).name
end
