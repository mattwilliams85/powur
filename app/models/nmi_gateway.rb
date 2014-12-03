class NmiGateway
  require 'HTTParty'

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
    @billing[:phone]     = user.email
    @billing[:address1]  = user.contact['address']
    @billing[:address2]  = user.contact['address']
    @billing[:city]      = user.contact['city']
    @billing[:state]     = user.contact['state']
    @billing[:zip]       = user.contact['zip']
    @billing[:phone]     = user.contact['phone']
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
    post_body[:username] = 'demo'
    post_body[:password] = 'password'
    post_body[:ccnumber] = sale_params[:number]
    post_body[:ccexp] = sale_params[:exp_date]
    post_body[:amount] = URI.escape('%.2f' % sale_params[:amount])
    post_body[:cvv] = sale_params[:security_code]
    post_body[:type] = 'sale'
  end

  def do_post(sale_params)
    post_body = build_post_body(sale_params)

    nmi_base_uri = 'https://secure.nmi.com'
    conn = Faraday.new(url: nmi_base_uri) do |faraday|
      faraday.request :url_encoded             # form-encode POST params
      faraday.adapter Faraday.default_adapter  # make requests with Net::HTTP
    end

    response = conn.post '/api/transact.php', post_body

    CGI.parse(response.body)
  end
end
