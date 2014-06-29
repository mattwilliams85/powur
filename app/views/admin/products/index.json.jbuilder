siren json

klass :products, :list

json.entities @products, partial: 'item', as: :product

actions \
  action(:create, :post, products_path).
    field(:name, :text).
    field(:commissionable_volume, :number)

links \
  link(:self, products_path)