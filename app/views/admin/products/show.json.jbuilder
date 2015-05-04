siren json

json.partial! 'item', product: @product, detail: true

actions \
  action(:update, :patch, product_path(@product))
  .field(:name, :text, value: @product.name)
  .field(:description, :text, value: @product.description)
  .field(:long_description, :text, value: @product.long_description)
  .field(:name, :text, value: @product.name)
  .field(:bonus_volume, :number, value: @product.bonus_volume)
  .field(:certifiable, :boolean, value: @product.certifiable)
  .field(:commission_percentage, :number,
         value:    @product.commission_percentage,
         required: false),
  action(:delete, :delete, product_path(@product))
