module Auth
  class UniversityClassesController < AuthController
    rescue_from Smarteru::Error, with: :smarteru_error

    page

    before_filter :find_university_class, only: [ :show, :enroll, :purchase ]
    before_filter :validate_class_availability, only: [ :enroll ]

    def index
      @university_classes = apply_list_query_options(Product.certifiable.sorted)
    end

    def purchase
      form = Forms::PurchaseUniversityClass.new(params[:card].merge(
        product_id: @university_class.id,
        amount: @university_class.bonus_volume/100
      ))
      if form.valid?
        if @university_class.purchase(form.as_json, current_user)
          PromoterMailer.certification_purchase_processed(current_user).deliver_now!
          if @current_user.upline.length > 1
            PromoterMailer.team_leader_downline_certification_purchase(current_user).deliver_now!
          end
          return head 200
        end
        render json: { errors: {number: ['Error, couldn\'t process a card']}}, status: :unprocessable_entity
      else
        render json: { errors: form.errors.messages }, status: :unprocessable_entity
      end
    end

    def enroll
      current_user.smarteru.ensure_account
      current_user.smarteru.enroll(@university_class)

      redirect_url = current_user.smarteru.signin
      render json: { redirect_to: redirect_url }
    end

    private

    def find_university_class
      @university_class = Product.certifiable.find(params[:id].to_i)
    end

    def validate_class_availability
      not_found!(:product) unless @university_class.is_free? || @university_class.purchased_by?(current_user)
      error!(:already_completed) if @university_class.completed_by?(current_user)
    end

    def smarteru_error(e)
      error!(:smarteru_user) if SmarteruClient::INACCESSABLE_ERROR == e.code
      fail e
    end
  end
end
