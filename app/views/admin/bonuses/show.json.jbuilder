siren json

json.partial! 'item', bonus: @bonus, detail: true

json.entities \
  [ { bonus: @bonus, data: @bonus.requirements, partial: 'requirements' },
    { bonus: @bonus, data: @bonus.bonus_levels, partial: 'bonus_levels' } ], 
  partial: 'entities', as: :entity


actions \
  action(:update, :patch, bonus_path(@bonus)).
    field(:name, :text, value: @bonus.name).
    field(:achieved_rank_id, :select, 
      reference:  { type: :link, rel: :ranks, value: :id, name: :title }, 
      value: @bonus.achieved_rank_id).
    field(:schedule, :select, options: Bonus::SCHEDULES, 
      value: @bonus.schedule).
    field(:pays, :select, options: Bonus::PAYS, 
      value: @bonus.pays).
    field(:max_user_rank_id, :select, 
      reference:  { type: :link, rel: :ranks, value: :id, name: :title }, 
      value: @bonus.max_user_rank_id,
      visibility: { control: :pays, value: :upline }).
    field(:min_upline_rank_id, :select, 
      reference:  { type: :link, rel: :ranks, value: :id, name: :title }, 
      value: @bonus.min_upline_rank_id,
      visibility: { control: :pays, value: :upline }).
    field(:compress, :checkbox, value: @bonus.compress,
      visibility: { control: :pays, value: :upline }).
    field(:levels, :checkbox, value: @bonus.levels,
      visibility: { control: :pays, value: :upline }),
  action(:delete, :delete, bonus_path(@bonus))

links \
  link(:self, bonus_path(@bonus)),
  link(:ranks, ranks_path),
  link(:products, products_path)

