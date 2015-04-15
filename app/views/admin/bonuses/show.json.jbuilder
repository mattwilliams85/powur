siren json

json.partial! 'item', bonus: @bonus, detail: true

bonus_json.detail_entities(@bonus)

links \
  link(:self, bonus_path(@bonus)),
  link(:ranks, ranks_path),
  link(:products, products_path)
