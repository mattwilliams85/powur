siren json

klass :product_receipts, :list

json.entities @receipts, partial: 'item', as: :product_receipt

actions \
  action(:create, :post, admin_user_product_receipts_path(@user))
    .field(:product, :select, options: Product.university_classes.where('bonus_volume > 0').where.not(id: @user.product_receipts.map(&:product_id)))

self_link admin_product_receipts_path(format: :json)