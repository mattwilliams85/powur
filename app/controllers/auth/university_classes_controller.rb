module Auth
  class UniversityClassesController < AuthController
    page

    before_filter :find_university_class, only: [:show, :enroll, :purchase]
    before_filter :validate_class_availability, only: [:enroll]

    def index
      @university_classes = apply_list_query_options(Product.certifiable)
    end

    def purchase
      form = Forms::PurchaseUniversityClass.new(params[:card].merge(
        product_id: @university_class.id,
        amount: @university_class.bonus_volume/100
      ))
      if form.valid?
        return head 200 if @university_class.purchase(form.as_json, current_user)
        render json: { errors: {number: ['Error, couldn\'t process a card']}}, status: :unprocessable_entity
      else
        render json: { errors: form.errors.messages }, status: :unprocessable_entity
      end
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
      head :unauthorized if @university_class.product_enrollments.find_by(user_id: current_user.id).try(:completed?)
      head :unauthorized unless @university_class.is_free? || @university_class.purchased_by?(current_user.id)
    end
  end
end
