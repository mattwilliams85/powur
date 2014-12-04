module Auth
  class EmpowerMerchantController < AuthController
    include EmpowerMerchantRequestHelper
    before_action :fetch_user

    def index
      respond_to do |format|
        format.html do
        end
        format.json do
        end
      end
    end

    def sandbox
    end

    def confirmation
      # Transaction Complete
    end

    def process_card
      @transaction = post_sale(params)
      if @transaction['response_code'] == '300'
        @receipt['responsetext'] = 'Error Connecting to Empower Merchant'
        @receipt['authcode'] = '0'
        @receipt['transactionid'] = '0'
      else
        @receipt = record_transaction(params['empower_merchant'], @transaction)
      end

      @receipt
    end

    def fetch_user
      @user = current_user
    end
  end
end
