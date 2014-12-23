class NmiGateway
  def initialize
    @login = {}
    @order = {}
    @billing = {}
    @shipping = {}
    @responses = {}
  end

  def set_login(username, password)
    @login['password'] = password
    @login['username'] = username
  end

  def set_billing(user)
    @billing[:firstname] = user.first_name
    @billing[:lastname]  = user.last_name
    @billing[:email]     = user.email
    @billing[:address1]  = user.contact['address']
    @billing[:address2]  = user.contact['address']
    @billing[:city]      = user.contact['city']
    @billing[:state]     = user.contact['state']
    @billing[:zip]       = user.contact['zip']
    @billing[:phone]     = user.contact['phone']
  end

  def billing_query_params
    query = ''
    query += '&firstname=' + @billing[:firstname].to_s
    query += '&lastname=' + @billing[:lastname].to_s
    query += '&phone=' + @billing[:phone].to_s
    query += '&address1=' + @billing[:address1].to_s
    query += '&address2=' + @billing[:address2].to_s
    query += '&city=' + @billing[:city].to_s
    query += '&state=' + @billing[:state].to_s
    query += '&zip=' + @billing[:zip].to_s
    query += '&email=' + @billing[:email].to_s
  end

  def do_sale(card_params)
    sale_params = {}
    sale_params[:amount] = card_params[:amount]
    sale_params[:number] = card_params[:number]
    sale_params[:security_code] = card_params[:security_code]
    sale_params[:exp_date] = card_params[:exp_date]
    sale_params[:product] = '1'
    do_post(sale_params)
  end

  def build_post_body(sale_params)
    post_body = @billing
    post_body[:username] = @login['username']
    post_body[:password] = @login['password']
    post_body[:ccnumber] = sale_params[:number]
    post_body[:ccexp] = sale_params[:exp_date]
    post_body[:amount] = URI.escape('%.2f' % sale_params[:amount])
    post_body[:cvv] = sale_params[:security_code]
    post_body[:type] = 'sale'
  end

  def build_post_query(sale_params)
    query = '?'
    query += '&username=demo'
    query += '&password=password'
    query += '&type=sale'
    query += '&ccnumber=' + sale_params[:number].to_s
    query += '&ccexp=' + sale_params[:exp_date]
    query += '&amount=' + URI.escape('%.2f' % sale_params[:amount])
    query += '&cvv=' + sale_params[:security_code]
    query += billing_query_params
    query
  end

  def do_post(sale_params)
    # post_body = build_post_body(sale_params)
    post_query = build_post_query(sale_params)

    nmi_base_uri = 'https://secure.nmi.com'
    conn = Faraday.new(url: nmi_base_uri) do |faraday|
      faraday.request :url_encoded             # form-encode POST params
      faraday.adapter Faraday.default_adapter  # make requests with Net::https
    end

    # response = conn.post '/api/transact.php', post_body
    response = conn.post("/api/transact.php/#{post_query}")

    CGI.parse(response.body)
  end
end
