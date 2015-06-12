module Auth
  class GoalsController < AuthController
    before_action :fetch_user
    before_action :fetch_rank

    def show
    end

    private

    def select_course_products(requirements)
      course_requirements = requirements.select(&:course_completion?)
      course_requirements.map(&:product_id).uniq
    end

    def select_sales_products(requirements)
      sales_requirements = requirements.select do |req|
        !req.course_completion?
      end
      sales_requirements.map(&:product_id).uniq
    end

    def fetch_rank
      next_rank_id = @user.organic_rank ? @user.organic_rank + 1 : 1
      @next_rank = Rank.find_by(id: next_rank_id)
      return unless @next_rank

      @requirements = @next_rank.user_groups.map(&:requirements).flatten
      course_product_ids = select_course_products(@requirements)
      @enrollments = ProductEnrollment.user_product(@user.id, course_product_ids)

      sales_product_ids = select_sales_products(@requirements)
      @order_totals = OrderTotal.where(
        user_id:       @user.id,
        pay_period_id: MonthlyPayPeriod.current.id)
    end
  end
end
