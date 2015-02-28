resources_json.item_init(local_assigns[:rel] || 'item')
resources_json.list_item_properties(resource)

actions \
  action(:show, :get, admin_resource_path(resource)),
  action(:update, :put, admin_resource_path(resource)),
  action(:destroy, :delete, admin_resource_path(resource))

links \
  link(:self, admin_resource_path(resource))
