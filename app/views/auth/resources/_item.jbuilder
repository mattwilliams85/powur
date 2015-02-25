resources_json.item_init(local_assigns[:rel] || 'item')
resources_json.list_item_properties(resource)

links \
  link(:self, resource_path(resource))
