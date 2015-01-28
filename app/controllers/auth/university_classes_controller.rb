module Auth
  class UniversityClassesController < AuthController
    page

    before_filter :find_university_class, only: [:show, :enroll]
    before_filter :validate_class_availability, only: [:enroll]

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

    def enroll
      head :unprocessable_entity unless current_user.create_smarteru_account
      head :unprocessable_entity unless current_user.smarteru_enroll(@university_class)
      redirect_url = current_user.smarteru_sign_in
      if redirect_url
        render json: { redirect_to: redirect_url }
      else
        head :unauthorized
      end
    end

    private

    def find_university_class
      @university_class = Product.certifiable.find(params[:id])
    end

    def validate_class_availability
      unless @university_class.is_free? || @university_class.purchased_by?(current_user.id)
        head :unauthorized
      end
    end
  end
end
