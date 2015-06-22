siren json

klass :resource_topics, :list

json.entities @resource_topics, partial: 'item', as: :resource_topic

actions \
  action(:create, :post, admin_resource_topics_path(format: :json))

self_link admin_resource_topics_path(format: :json)
