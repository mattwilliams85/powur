module Auth
  class UniversityClassesController < AuthController
    page

    before_filter :find_university_class, only: [:show]

    def index
      @university_classes = apply_list_query_options(Product.certifiable)
    end

    def purchase
      # @transaction = post_sale(params)
      #
      # if @transaction['response_code'].first == '300'
      #   @receipt['responsetext'] = 'Error Connecting to Empower Merchant'
      #   @receipt['authcode'] = '0'
      #   @receipt['transaction_id'] = '0'
      # else
      #   @receipt = record_transaction(params, @transaction)
      # end
    end

    private

    def find_university_class
      @university_class = Product.certifiable.find(params[:id])
    end
  end
end
