module Auth
  class GoalsController < AuthController
    before_action :fetch_user

    def show
      next_rank_id = @user.organic_rank ? @user.organic_rank + 1 : 1
      @next_rank = Rank.find_by(id: next_rank_id)
      return unless @next_rank

      @requirements = @next_rank.user_groups.map(&:requirements).flatten
      course_product_ids = select_course_products(@requirements)
      @enrollments = ProductEnrollment.user_product(@user.id, course_product_ids)

    #   @order_totals = product_ids.map do |product_id|
    #     pay_period.find_order_total(@user.id, product_id)
    #   end.compact
    end

    private

    def select_course_products(requirements)
      course_requirements = requirements.select(&:course_completion?)
      course_requirements.map(&:product_id).uniq
    end
  end
end
