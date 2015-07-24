module Auth
  class EwalletController < AuthController
    include EwalletDSL

    def account_details
      @ewallet_account_details = get_ewallet_customer_details(current_user)
    end
  end
end
