module EmpowerMerchantRequestHelper
  def post_sale(params)
    puts "POST SALE PARAMS:"
    ap params
    card_params = { amount:         params[:amount],
                    number:         params[:number],
                    security_code:  params[:security_code],
                    exp_date:       params[:expiration_month].to_s +
                                    '/' + params[:expiration_year].to_s,
                    product_id:     params[:product_id].to_s
                  }
    nmi_gateway = NmiGateway.new
    username = Rails.application.secrets[:nmi_username]
    password = Rails.application.secrets[:nmi_password]

    nmi_gateway.set_login(username, password)
    nmi_gateway.set_billing(current_user)
    response = nmi_gateway.do_sale(card_params)
    puts "RESPONSE FROM doSale"
    puts response.to_hash
    response.to_hash
  end

  def record_transaction(transaction)
    puts '***record transaction'
    puts 'transaction'
    ap transaction
    product = Product.find(1)
    receipt = ProductReceipt.create(product_id:     product.id,
                                    user_id:        current_user.id,
                                    amount:         transaction[:amount],
                                    transaction_id: transaction[:transactionid],
                                    order_id:       transaction[:orderid])
    receipt
  end
end
