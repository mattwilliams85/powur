klass :qualifications, :list

qual_json.list_entities('admin/qualifications/rank_item', qualifications)

actions qual_json.create_action(rank_qualifications_path(rank))

links link(:products, products_path)
