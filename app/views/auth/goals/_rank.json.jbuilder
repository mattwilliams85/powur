ranks_json.item_init(local_assigns[:rel] || 'item')

ranks_json.properties(rank)

json.properties do
  json.product_ids rank.qualifications.map(&:product_id)
end


ranks_json.user_entities(rank)
