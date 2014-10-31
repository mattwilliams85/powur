module Auth
  class GoalsController < AuthController
    def show
      @user = fetch_downline_user(params[:user_id].to_i)
      pay_period = MonthlyPayPeriod.current
      @pay_as_rank = pay_period.find_pay_as_rank(@user)

      @ranks = all_ranks
      product_ids = @ranks.map(&:qualifications).flatten.map(&:product_id).uniq
      @order_totals = product_ids.map do |product_id|
        pay_period.find_order_total(@user.id, product_id)
      end
    end
  end
end