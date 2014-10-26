module QuotesJson
  def quote_klass(json)
    siren json
    klass :quote

    detail_properties if @quote
  end

  def quotes_klass(json)
    siren json

    klass :quotes, :list

    list_items
  end

  def list_item_properties(quote = @quote)
    json.properties do
      json.call(quote, :id, :data_status)
      json.call(quote.customer, :first_name, :last_name, :full_name)
    end
  end

  def admin_list_item_properties(quote = @quote)
    json.properties do
      json.call(quote, :id, :data_status, :created_at)
      json.user quote.user.full_name
      json.customer quote.customer.full_name
      json.product quote.product.name
    end
  end

  def list_items
    json.entities @quotes, partial: 'item', as: :quote
  end

  def detail_properties
    list_item_properties

    json.properties do
      json.call(@quote.customer, :email, :phone, :address, :city, :state, :zip)
      @quote.data.each { |key, value| json.set! key, value }
    end
  end

  def detail_entities(context)
    list = [
      entity("#{context}/products/item",
             'quote-product',
             product: @quote.product),
      entity("#{context}/users/item",
             'quote-user',
             user: @quote.user),
      entity("#{context}/customers/item",
             'quote-customer',
             customer: @quote.customer) ]

    if @quote.order?
      list << entity("#{context}/orders/item",
                     'quote-order',
                     order: @quote.order)
    end

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

  def customer_create_action
    create_action(quote_path)
      .field(:email, :email)
      .field(:phone, :text)
      .field(:promoter, :hidden, value: @sponsor.url_slug)
  end

  def user_create_action
    action = create_action(user_quotes_path)
      .field(:email, :email, required: false)
      .field(:phone, :text, required: false)

    Product.default.quote_data.each do |key|
      action.field(key, :text, required: false)
    end

    action
  end

  def update_action(path)
    action = action(:update, :patch, path)
      .field(:first_name, :text, value: @quote.customer.first_name)
      .field(:last_name, :text, value: @quote.customer.last_name)
      .field(:email, :email, required: false, value: @quote.customer.email)
      .field(:phone, :text, required: false, value: @quote.customer.phone)
      .field(:address, :text, required: false, value: @quote.customer.address)
      .field(:city, :text, required: false, value: @quote.customer.city)
      .field(:state, :text, required: false, value: @quote.customer.state)
      .field(:zip, :text, required: false, value: @quote.customer.zip)

    @quote.data.each do |key, value|
      action.field(key, :text, required: false, value: value)
    end

    action
  end

  def resend_action(path)
    action(:resend, :post, path)
  end
end
