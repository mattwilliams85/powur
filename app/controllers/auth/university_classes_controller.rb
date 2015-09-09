module Auth
  class UniversityClassesController < AuthController
    rescue_from Smarteru::Error, with: :smarteru_error

    page

    before_filter :find_university_class, only: [ :show, :enroll, :purchase ]
    before_filter :find_enrollment, only: [ :check_enrollment, :smarteru_signin ]

    def index
      @university_classes = apply_list_query_options(
        Product.university_classes.sorted)
    end

    def purchase
      process_purchase
      Rank.rank_user(current_user.id)
      current_user.reload

      send_purchased_notifications
      update_mailchimp

      head :ok
    end

    def enroll
      validate_class_enrollable
      current_user.smarteru.ensure_account
      current_user.smarteru.enroll(@university_class)

      redirect_url = current_user.smarteru.signin
      render json: { redirect_to: redirect_url }
    end

    def smarteru_signin
      current_user.smarteru.ensure_account
      error!(:smarteru_incomplete_enrollment) unless @enrollment.completed?

      render json: { redirect_to: current_user.smarteru.signin }
    end

    def check_enrollment
      @enrollment.refresh_enrollment_status
      @university_class = @enrollment.product

      render :show
    end

    private

    def find_university_class
      @university_class = Product.university_classes.find(params[:id].to_i)
    end

    def find_enrollment
      @enrollment = current_user.product_enrollments.find_by(
        product_id: params[:id].to_i)
      error!("Error, couldn't find enrollment") unless @enrollment
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
      error!(number: ['We are unable to process this card. \
        Please reenter your number and secret code or try a different card.'])
    end

    def send_purchased_notifications
      mailer = PromoterMailer.certification_purchase_processed(current_user)
      mailer.deliver_now!

      return unless current_user.upline.length > 1
      mailer = PromoterMailer
        .team_leader_downline_certification_purchase(current_user)
      mailer.deliver_now!
    end

    def update_mailchimp
      current_user.mailchimp_update_subscription
    rescue Gibbon::MailChimpError => e
      Airbrake.notify(e)
    end

    def validate_class_enrollable
      if (!@university_class.free? &&
          !@university_class.purchased_by?(current_user)) ||
          !@university_class.prerequisites_taken?(current_user)
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
