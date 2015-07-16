klass :product_enrollment

json.properties do
  json.call(product_enrollment,
            :id,
            :product_id,
            :user_id,
            :state,
            :created_at,
            :updated_at)
  json.product Product.find(product_enrollment.product_id)
  json.user User.find(product_enrollment.user_id)
end
