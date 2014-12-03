siren json

klass :products, :list

json.entities @products, partial: 'item', as: :product

actions \
  action(:create, :post, products_path)
  .field(:name, :text)
  .field(:bonus_volume, :number)
  .field(:commission_percentage, :number, default: 100)

links link(:self, products_path)
