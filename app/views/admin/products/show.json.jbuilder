siren json

json.partial! 'item', product: @product, detail: true

json.properties do
  json.(@product, :commissionable_volume, :commission_percentage, :quote_data)
end

actions \
  action(:update, :patch, product_path(@product)).
    field(:name, :text, value: @product.name).
    field(:commissionable_volume, :number, value: @product.commissionable_volume).
    field(:commission_percentage, :number, value: @product.commission_percentage, required: false),
  action(:delete, :delete, product_path(@product))

