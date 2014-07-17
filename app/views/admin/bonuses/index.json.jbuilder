siren json

klass :bonuses, :list

json.properties do
end

json.entities @bonuses, partial: 'item', as: :bonus

actions \
  action(:create, :post, bonuses_path).
    field(:name, :text)

links \
  link(:self, bonuses_path)