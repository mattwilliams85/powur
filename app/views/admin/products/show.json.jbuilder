siren json

json.partial! 'item', product: @product, detail: true

actions \
  action(:update, :patch, product_path(@product))
  .field(:name, :string, value: @product.name)
  .field(:description, :text, value: @product.description)
  .field(:long_description, :text, value: @product.long_description)
  .field(:bonus_volume, :number, value: @product.bonus_volume)
  .field(:is_university_class, :boolean, value: @product.is_university_class)
  .field(:commission_percentage, :number,
         value:    @product.commission_percentage,
         required: false)
  .field(:image_original_path, :string, value: @product.image_original_path),
  action(:delete, :delete, product_path(@product))
