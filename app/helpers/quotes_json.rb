class QuotesJson < JsonDecorator
  def list_init(partial_path = 'item')
    klass :quotes, :list

    list_entities(partial_path)
  end

  def item_init(rel = nil)
    klass :quote

    entity_rel(rel) if rel
  end

  def list_item_properties(quote = @item)
    json.properties do
      json.call(quote, :id, :data_status, :created_at)
      json.user quote.user.full_name
      json.customer quote.customer.full_name
      json.product quote.product.name
    end
  end

  def list_entities(partial_path, list = @list)
    json.entities list, partial: partial_path, as: :quote
  end

  def detail_properties(quote = @item)
    list_item_properties

    json.properties do
      json.call(quote.customer, :email, :phone, :address, :city, :state, :zip)
      quote.data.each { |key, value| json.set! key, value }
    end
  end

  def user_entities(quote = @item)
    entities(order_entity('auth', quote)) if quote.order?
  end

  def admin_entities(quote = @item)
    list = [ product_entity('admin', quote),
             user_entity('admin', quote),
             customer_entity('admin', quote) ]

    list << order_entity('admin', quote) if quote.order?

    entities(*list)
  end

  def create_action(path)
    action(:create, :post, path)
      .field(:first_name, :text)
      .field(:last_name, :text)
      .field(:address, :text, required: false)
      .field(:city, :text, required: false)
      .field(:state, :text, required: false)
      .field(:zip, :text, required: false)
  end

  def customer_create_action(user_slug)
    create_action(quote_path)
      .field(:email, :email)
      .field(:phone, :text)
      .field(:promoter, :hidden, value: user_slug)
  end

  def user_create_action
    action = create_action(request.path)
             .field(:email, :email, required: false)
             .field(:phone, :text, required: false)

    action_quote_fields(action)

    action
  end

  def update_action(path)
    action = action(:update, :patch, path)
             .field(:first_name, :text, value: @item.customer.first_name)
             .field(:last_name, :text, value: @item.customer.last_name)
             .field(:email, :email, required: false, value: @item.customer.email)
             .field(:phone, :text, required: false, value: @item.customer.phone)
             .field(:address, :text, required: false, value: @item.customer.address)
             .field(:city, :text, required: false, value: @item.customer.city)
             .field(:state, :text, required: false, value: @item.customer.state)
             .field(:zip, :text, required: false, value: @item.customer.zip)

    action_quote_fields(action) do |field, opts|
      opts[:value] = field.normalize(@item.data[field.name])
    end

    action
  end

  def resend_action(path)
    action(:resend, :post, path)
  end

  private

  def product_entity(context, quote)
    entity("#{context}/products/item", 'quote-product',
           product: quote.product)
  end

  def customer_entity(context, quote)
    entity("#{context}/customers/item", 'quote-customer',
           customer: quote.customer)
  end

  def user_entity(context, quote)
    entity("#{context}/users/item", 'quote-user',
           user: quote.user)
  end

  def order_entity(context, quote)
    entity("#{context}/orders/item", 'quote-order',
           order: quote.order)
  end

  def action_quote_fields(quote_action)
    product = Product.default || return
    product.quote_fields.each do |field|
      opts = { required: field.required }
      if field.lookup?
        lookups = field.lookups.sort_by { |i| [ i.group, i.value ] }
        next if lookups.empty?
        opts[:options] = lookups.map do |lookup|
          attrs = { display: lookup.value }
          attrs[:group] = lookup.group if lookup.group
          attrs
        end
      end
      yield(field, opts) if block_given?
      quote_action.field(field.name, field.view_type, opts)
    end
  end
end
