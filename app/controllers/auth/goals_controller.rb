module Auth
  class GoalsController < AuthController
    helper QualificationsJson
    helper OrderTotalsJson

    def show
      @user = fetch_downline_user(params[:user_id].to_i)
      pay_period = MonthlyPayPeriod.current
      @pay_as_rank = pay_period.find_pay_as_rank(@user)

      @next_rank = Rank.find_by_id(@pay_as_rank + 1)
      @qualifications = 
        if @next_rank
          @next_rank.qualifications
        else
          @pay_as_rank.qualifications
        end
      product_ids = @qualifications.map(&:product_id).uniq
      @order_totals = product_ids.map do |id|
        pay_period.find_order_total(@user.id, id)
      end
    end
  end
end