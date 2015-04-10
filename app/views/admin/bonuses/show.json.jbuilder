siren json

json.partial! 'item', bonus: @bonus, detail: true

links \
  link(:self, bonus_path(@bonus)),
  link(:ranks, ranks_path),
  link(:products, products_path)
