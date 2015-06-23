siren json

klass :resources, :list

json.entities @resources, partial: 'item', as: :resource

json.properties do
  json.topics do
    json.entities @topics
  end
end

self_link resources_path
