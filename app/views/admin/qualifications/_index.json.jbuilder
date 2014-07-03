
klass :qualifications, :list

json.entities qualifications, partial: 'admin/qualifications/item', as: :qualification

create_action = action(:create, :post, rank_qualifications_path(rank)).
  field(:path, :text, value: 'default').
  field(:type, :select, 
    options: { 
      certification: 'Certification', 
      sales:         'Personal Sales', 
      group_sales:   'Group Sales' }, value: :sales).
  field(:name, :text, on: [ :certification ]).
  field(:product_id, :select,
    reference: { type: :link, rel: :products, value: :id, name: :name }, 
    on: [ :sales, :group_sales ]).
  field(:period, :select, options: { pay_period: 'Pay Period', lifetime: 'Lifetime' }, on: [ :sales, :group_sales ]).
  field(:quantity, :number, on: [ :sales, :group_sales ]).
  field(:max_leg_percent, :number, on: [ :group_sales ])

actions \
  create_action

links \
  link(:products, products_path)
