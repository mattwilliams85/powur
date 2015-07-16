siren json

klass :product_receipts, :list

json.entities @receipts, partial: 'item', as: :product_receipt

self_link admin_product_receipts_path(format: :json)