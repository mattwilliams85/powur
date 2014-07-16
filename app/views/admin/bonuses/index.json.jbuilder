siren json

klass :bonuses, :list

json.properties do
end

json.entities @bonuses, partial: 'item', as: :bonus

actions \
  action(:create, :post, bonuses_path).
    field(:name, :text).
    field(:schedule, :select, options: Bonus::SCHEDULES, value: :pay_period).
    field(:product_id, :select, 
      reference:  { type: :link, rel: :products, value: :id, name: :name }).
    field(:schedule, :select, options: Bonus::PAYS, value: :distributor).
    field(:compression, :checkbox, value: false, 
      visibility: { control: :schedule, values: [ :upline ] }).
    field(:min_distributor_rank, :select,
      reference: { type: :link, rel: :ranks, value: :id, name: :name }, 
      visibility: { control: :schedule, values: [ :upline ] }).
    field(:max_upline_rank, :select,
      reference: { type: :link, rel: :ranks, value: :id, name: :name }, 
      visibility: { control: :schedule, values: [ :upline ] }).
    field(:levels, :checkbox, value: false,
      visibility: { control: :schedule, values: [ :upline ] }).
    field(:amount, :number, array: true, size: Rank.count, visibility: { control: :levels, values: [ false ] })

links \
  link(:self, bonuses_path),
  link(:ranks, ranks_path),
  link(:products, products_path)