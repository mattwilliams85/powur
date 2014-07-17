siren json

json.partial! 'item', bonus: @bonus, detail: true

json.entities \
  [ { bonus: @bonus, data: @bonus.requirements, partial: 'requirements' } ], 
  partial: 'entities', as: :entity


actions \
  action(:update, :patch, bonus_path(@bonus)).
    field(:name, :text, value: @bonus.name)

links \
  link(:self, bonus_path(@bonus)),
  link(:ranks, ranks_path),
  link(:products, products_path)

