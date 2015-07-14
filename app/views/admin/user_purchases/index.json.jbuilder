siren json

klass :product_receipts, :list

json.entities @user.product_receipts, partial: 'item', as: :product_receipt

links \
  link(:self, admin_user_purchases_path(@user))