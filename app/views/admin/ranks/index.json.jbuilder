siren json

klass :ranks, :list

json.properties do
  json.paths @ranks.map { |r| r.qualifications.map(&:path) }.flatten.uniq
end

json.entities @ranks, partial: 'item', as: :rank

actions \
  action(:create, :post, ranks_path).
    field(:title, :text)

links \
  link(:self, ranks_path)