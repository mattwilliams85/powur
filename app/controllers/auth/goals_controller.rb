module Auth
  class GoalsController < AuthController
    before_action :fetch_user
    before_action :fetch_rank

    def show
    end

    private

    def fetch_purchases(requirements)
      purchase_requirements = requirements.select(&:purchase?)
      product_ids = purchase_requirements.map(&:product_id).uniq
      @purchases = ProductReceipt.where(
        product_id: product_ids,
        user_id:    @user.id)
    end

    def fetch_order_totals(requirements)
      sales_requirements = requirements.reject(&:purchase?)
      product_ids = sales_requirements.map(&:product_id).uniq

      @order_totals = OrderTotal.where(
        product_id:    product_ids,
        user_id:       @user.id,
        pay_period_id: MonthlyPayPeriod.current.id)
    end

    def fetch_rank
      next_rank_id = @user.organic_rank ? @user.organic_rank + 1 : 1
      @next_rank = Rank.find_by(id: next_rank_id)
      return unless @next_rank

      @requirements = @next_rank.user_groups.map(&:requirements).flatten

      fetch_purchases(@requirements)
      fetch_order_totals(@requirements)
    end
  end
end
