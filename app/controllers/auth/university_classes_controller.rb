module Auth
  class UniversityClassesController < AuthController
    rescue_from Smarteru::Error, with: :smarteru_error

    page

    before_filter :find_university_class, only: [ :show, :enroll, :purchase ]
    before_filter :find_enrollment, only: [ :check_enrollment ]

    def index
      @university_classes = apply_list_query_options(
        Product.university_classes.sorted)
    end

    def purchase
      process_purchase
      send_purchased_notifications
      increase_available_invites

      head :ok
    end

    def enroll
      validate_class_enrollable
      current_user.smarteru.ensure_account
      current_user.smarteru.enroll(@university_class)

      redirect_url = current_user.smarteru.signin
      render json: { redirect_to: redirect_url }
    end

    def check_enrollment
      error!("Error, couldn't find enrollment") unless @enrollment
      @enrollment.refresh_enrollment_status
    end

    private

    def find_university_class
      @university_class = Product.university_classes.find(params[:id].to_i)
    end

    def find_enrollment
      @enrollment = current_user.product_enrollments.find_by(
        product_id: params[:id].to_i)
    end

    def puchase_form
      @puchase_form ||= begin
        form_args = params[:card].merge(
          product_id: @university_class.id,
          amount:     @university_class.bonus_volume / 100)
        Forms::PurchaseUniversityClass.new(form_args)
      end
    end

    def process_purchase
      error!(puchase_form.errors.messages) unless puchase_form.valid?

      return if @university_class.purchase(puchase_form.as_json, current_user)
      error!("Error, couldn't process a card", :number)
    end

    def send_purchased_notifications
      mailer = PromoterMailer.certification_purchase_processed(current_user)
      mailer.deliver_now!
      if @current_user.upline.length > 1
        mailer = PromoterMailer
          .team_leader_downline_certification_purchase(current_user)
        mailer.deliver_now!
      end
    end

    def increase_available_invites
      current_user.update_column(:available_invites, current_user.available_invites + 5)
    end

    def validate_class_enrollable
      unless @university_class.is_free? ||
          @university_class.purchased_by?(current_user)
        not_found!(:product)
      end
      return unless @university_class.completed_by?(current_user)
      error!(:already_completed)
    end

    def smarteru_error(e)
      error!(:smarteru_user) if SmarteruClient::INACCESSABLE_ERROR == e.code
      fail e
    end
  end
end
