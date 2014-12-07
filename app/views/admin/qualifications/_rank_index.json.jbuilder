klass :qualifications, :list

entity_rel('rank-qualifications')

qual_json.list_entities('admin/qualifications/rank_item', qualifications)

unless all_paths.empty? || all_products.empty?
  actions qual_json.rank_create_action(rank)
end

links link(:products, products_path)
