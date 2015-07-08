siren json

klass :quotes, :list

json.entities @quotes, partial: 'item', as: :quote

create = action(:create, :post, request.path)
  .field(:first_name, :text)
  .field(:last_name, :text)
  .field(:address, :text, required: false)
  .field(:city, :text, required: false)
  .field(:state, :text, required: false)
  .field(:zip, :text, required: false)
  .field(:notes, :text, required: false)

product = Product.default
if product
  product.quote_fields.each do |field|
    opts = { required: field.required, product_field: true }

    if field.lookup?
      lookups = field.lookups.sort_by { |i| [ i.group, i.value ] }
      next if lookups.empty?
      opts[:options] = lookups.map do |lookup|
        attrs = { display: lookup.value }
        attrs[:group] = lookup.group if lookup.group
        attrs
      end
    end

    create.field(field.name, field.view_type, opts) if create
  end
end

actions_list = [
  index_action(request.path, true),
  create
]
actions(*actions_list)

self_link request.path
