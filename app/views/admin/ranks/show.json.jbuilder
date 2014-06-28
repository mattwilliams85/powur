siren json

json.partial! 'item', rank: @rank, detail: true

json.properties do
  json.(@rank, :id, :title)
end

links \
  link(:self, rank_path(@rank))

