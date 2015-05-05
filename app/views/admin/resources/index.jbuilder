siren json

klass :resources, :list

json.entities @resources, partial: 'item', as: :resource

actions \
  action(:create, :post, admin_resources_path(format: :json))

self_link admin_resources_path(format: :json)
