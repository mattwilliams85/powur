siren json

klass :orders, :list

json.entities @orders, partial: 'item', as: :order

actions \
	index_action(@orders_path).field(:search, :search, required: false)
	
    

links link(:self, @orders_path || orders_path)
