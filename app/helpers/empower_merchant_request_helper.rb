module EmpowerMerchantRequestHelper
  def post_sale(params)
    card_params = { amount:        params[:amount],
                    number:        params[:number],
                    security_code: params[:security_code],
                    exp_date:      params[:expiration_month].to_s + '/' +
                                   params[:expiration_year].to_s,
                    product_id:    params[:product_id].to_s }
    nmi_gateway = NmiGateway.new
    username = Rails.application.secrets[:nmi_username]
    password = Rails.application.secrets[:nmi_password]

    nmi_gateway.set_login(username, password)

    nmi_gateway.set_billing(current_user)
    response = nmi_gateway.do_sale(card_params)
    response
  end

  def record_transaction(transaction, response)
    receipt = ProductReceipt.create(product_id:     transaction['product_id'],
                                    user_id:        current_user.id,
                                    amount:         transaction['amount'],
                                    transaction_id: response['transactionid'].first,
                                    auth_code:      response['authcode'].first,
                                    order_id:       response['orderid'].first)

    receipt
  end
end
