siren json

klass :product_enrollments, :list

json.entities @product_enrollments, partial: 'item', as: :product_enrollment

self_link admin_product_enrollments_path(format: :json)