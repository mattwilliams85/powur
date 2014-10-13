siren json

json.partial! 'item', bonus: @bonus, detail: true

json.partial! @bonus.type_string, bonus: @bonus

links \
  link(:self, bonus_path(@bonus)),
  link(:ranks, ranks_path),
  link(:products, products_path)
