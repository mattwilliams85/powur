siren json

qual_json.list_init('admin/qualifications/item')

unless all_paths.empty? || all_products.empty?
  actions qual_json.create_action(qualifications_path) unless all_paths.empty?
end

self_link qualifications_path
