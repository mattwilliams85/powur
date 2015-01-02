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
    @billing = {
      firstname: user.first_name,
      lastname:  user.last_name,
      email:     user.email,
      address1:  user.contact['address'],
      address2:  user.contact['address'],
      city:      user.contact['city'],
      state:     user.contact['state'],
      zip:       user.contact['zip'],
      phone:     user.contact['phone']
    }

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
    params = {
      amount: card_params[:amount],
      number: card_params[:number],
      security_code: card_params[:security_code],
      exp_date: card_params[:exp_date],
      product: '1'
    }

    do_post(params)
  end

  def build_post_body(sale_params)
    post_body = @billing
    post_body.merge(
                      username: @login['username'],
                      password: @login['password'],
                      ccnumber: sale_params[:number],
                      ccexp:    sale_params[:exp_date],
                      amount:   URI.escape('%.2f' %
                                            sale_params[:amount]),
                      cvv:      sale_params[:security_code],
                      type:     'sale')
  end

  def build_post_query(sale_params)
    query = "?&username=demo&password=password&type=sale&ccnumber=%s&ccexp=%s&amount=%s&cvv=%s" %
            [sale_params[:number].to_s,
            sale_params[:exp_date],
            URI.escape('%.2f' % sale_params[:amount]),
            sale_params[:security_code]]
    query += billing_query_params
  end

  def do_post(sale_params)
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
