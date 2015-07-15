siren json

klass :product_receipts, :list

json.entities @receipts, partial: 'item', as: :product_receipt