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
    # return do_get(sale_params)
  end

  def do_get(sale_params)
    query  = ''
    # Login Information
    query = query + 'username=' + URI.escape(@login['username']) + '&'
    query += 'password=' + URI.escape(@login['password']) + '&'
    # Sales Information
    query += 'ccnumber=' + URI.escape(sale_params[:number]) + '&'
    query += 'ccexp=' + URI.escape(sale_params[:exp_date]) + '&'
    query += 'amount=' + URI.escape('%.2f' % sale_params[:amount]) + '&'
    if (sale_params[:security_code] != '')
      query += 'cvv=' + URI.escape(sale_params[:security_code]) + '&'
    end

    @billing.each do | key, value|
      if !value.blank?
        query += key + '=' + URI.escape(value) + '&' + query
      end
    end

    query += 'type=sale'
    nmi_uri = 'https://secure.nmi.com/api/transact.php?&'
    request_body = { body:    [ post_body ].to_json,
                     headers: { 'Content-Type' => 'application/json',
                                'Accept' =>       'application/json'}
                   }

    response = HTTParty.get(nmi_uri, request_body)
    response
  end

  def do_post(sale_params)
    post_body = @billing
    post_body[:username] = @login['username']
    post_body[:password] = @login['password']
    post_body[:ccnumber] = sale_params[:number]
    post_body[:ccexp] = sale_params[:exp_date]
    post_body[:amount] = URI.escape('%.2f' % sale_params[:amount])
    post_body[:cvv] = sale_params[:security_code]
    post_body[:type] = 'sale'
    headers = { 'Content-Type' => 'application/json',
                'Accept'       => 'application/json' }
    nmi_uri = 'https://secure.nmi.com/api/transact.php'
    response = HTTParty.post(nmi_uri,  body:    [ post_body ].to_json,
                                       headers: headers)

    response
  end
end
