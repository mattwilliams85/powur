siren json

json.partial! 'item', bonus: @bonus, detail: true

if @bonus.source_requirement?
  json.properties do
    json.available_bonus @bonus.available_bonus_amount
    json.available_bonus_percentage @bonus.available_bonus_percentage
  end
end

json.partial! @bonus.type_string, bonus: @bonus

links \
  link(:self, bonus_path(@bonus)),
  link(:ranks, ranks_path),
  link(:products, products_path)

