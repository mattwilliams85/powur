siren json

klass :qualifications, :list

json.entities @qualifications, partial: 'admin/qualifications/item', as: :qualification

actions action(:create, :post, qualifications_path).
  field(:path, :text, value: 'default').
  field(:type, :select,
    options: Qualification::TYPES, value: :sales).
  field(:product_id, :select, 
    reference:  { type: :link, rel: :products, value: :id, name: :name }).
  field(:period, :select, options: Qualification::PERIODS, value: :pay_period).
  field(:quantity, :number).
  field(:max_leg_percent, :number, 
    visibility: { control: :type, values: [ :group_sales ] })


links \
  link(:self, qualifications_path),
  link(:products, products_path)
